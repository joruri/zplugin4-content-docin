class Docin::BuildService < ApplicationService
  def initialize(content, user)
    @content = content
    @user = user
    @group = nil


    @dest_content = @content.gp_article_content
    @category_types = @dest_content.category_types.map do |category_type|
                        [category_type.title, category_type.categories]
                      end.to_h
    @event_categories = @dest_content.event_category_types.flat_map(&:categories)
    @marker_categories = @dest_content.marker_category_types.flat_map(&:categories)

    @body_template = Erubis::Eruby.new(@content.body_template)
    @summary_template = Erubis::Eruby.new(@content.summary_template)
    @dictionary = @content.column_replace_dictionary
  end

  def build(row, doc: nil)
    doc_content = set_doc_content(@content, @dest_content, row)
    if @content.setting.quota_column.present? && @dest_content.id != doc_content.id
      doc = doc_content.docs.where(name: row.name).where.not(state: 'trashed').first_or_initialize
    else
      doc ||= doc_content.docs.where(name: row.name).where.not(state: 'trashed').first_or_initialize
    end
    doc.state = row.state
    doc.title = row.title
    doc.body = @body_template.evaluate(data: replace_data(row))
    doc.summary = @summary_template.evaluate(data: replace_data(row))
    doc.concept = @dest_content.concept
    doc.display_updated_at = row.display_updated_at unless row.display_updated_at.nil?
    doc.display_published_at = row.display_published_at unless row.display_published_at.nil?
    doc.keep_display_updated_at = row.keep_display_updated_at
    doc.tasks_attributes = tasks_attributes(doc, row)
    doc.recognized_at = Time.now
    doc.qrcode_state = 'visible'
    doc.feature_1 = row.feature_1 unless row.feature_1.nil?
    doc.feed_state = row.feed_state unless row.feed_state.nil?
    doc.list_image = build_list_image(row)

    # template
    set_template(doc, row)

    # group user
    set_user_group(row)

    # creator editor
    build_creator_or_editor(doc)

    # inquiry
    build_inquiries(doc, row)

    # event
    build_event(doc, row)

    # map
    build_map(doc, row)

    # category
    if @content.setting.category_relation.present?
      build_categories_in_import(doc, row)
    elsif @content.setting.category_column_regexp.present?
      build_categories_from_regexp(doc, row)
    else
      build_categories(doc, row)
    end

    if @content.default_category_ids.present?
      build_default_categories(doc, row)
    end

    # file
    if @content.setting.attachement_directory.blank? || @content.setting.attachement_column.blank?
      build_file(doc, row)
    else
      build_file_in_import(doc, row)
    end

    doc.in_ignore_accessibility_check = '1'
    doc.in_ignore_link_check = '1'

    doc
  end

  private

  def set_doc_content(content, dest_content, row)
    if content.setting.quota_column.present?
      row.data.headers.each do |key|
        next if key !~ /#{content.setting.quota_column}/
        content_id = content.quota_content_dictionary[row.data[key]]
        next if content_id.blank?
        set_content = GpArticle::Content::Doc.find_by(id: content_id)
        return set_content if set_content.present?
      end
    end
    return dest_content
  end

  def set_user_group(row)
    if @content.setting.creator_group_code
      org_code = @content.org_dictionary[row.data[@content.setting.creator_group_code]] || row.data[@content.setting.creator_group_code]
      @group = @content.site.groups.find_by(code: org_code)
      g_cuser = @group.users.find_by(auth_no: 2) if @group.present?
    elsif @content.setting.creator_group_name
      @group = @content.site.groups.find_by(name: row.data[@content.setting.creator_group_name])
      g_cuser = @group.users.find_by(auth_no: 2) if @group.present?
    end
    if @content.setting.creator_user_code
      cuser = @content.site.users.find_by(account: row.data[@content.setting.creator_user_code])
    elsif @content.setting.creator_user_name
      cuser = @content.site.users.find_by(name: row.data[@content.setting.creator_user_name])
    end
    @user = cuser || g_cuser || @user
  end

  def replace_data(row)
    return row.data if @dictionary.blank?
    data = row.data.dup
    data.each_entry do |key|
      next if key.blank?
      next if @dictionary[key[0]].blank?
      data[key[0]] = @dictionary[key[0]][key[1]] if @dictionary[key[0]][key[1]].present?
     end
    data
  end

  def tasks_attributes(doc, row)
    {
      '0': {
        id: doc.task_for(:publish)&.id,
        name: 'publish',
        process_at: row.task_publish_process_at
      },
      '1': {
        id: doc.task_for(:close)&.id,
        name: 'close',
        process_at: row.task_close_process_at
      }
   }
  end

  def set_template(doc, row)
    if @content.setting.template.blank?
      doc.template_id = nil
    else
      template_values = @content.setting.template_values.dup
      template_values.each do |k, v|
        template_values[k] = Erubis::Eruby.new(v).evaluate(data: row.data)
      end
      doc.template_id = @content.setting.template.id
      doc.template_values = template_values
    end
  end

  def build_creator_or_editor(doc)
    if doc.creator.blank?
      doc.build_creator
      doc.creator.user = @user
      doc.creator.group = @group || @user.group
    else
      doc.creator.user = @user
      doc.creator.group = @group || @user.group
      doc.build_editor if doc.editor.blank?
      doc.editor.user = @user
      doc.editor.group = @group || @user.group
    end
  end

  def build_inquiries(doc, row)
    if doc.inquiries.blank?
      doc.inquiries.build
      inquiry = doc.inquiries[0]
      inquiry.group = doc.creator.group
    else
      inquiry = doc.inquiries[0]
      inquiry.group = doc.creator.group
    end
    old_group =  @content.site.groups.find_by(code: row.data[@content.setting.creator_group_code])
    if old_group.present?
      if @content.setting.org_inquiry_relation_type == 1
        inquiry2 = doc.inquiries[1] || doc.inquiries.build
        inquiry2.group = old_group
      elsif @content.setting.org_inquiry_relation_type == 2
        inquiry.group = old_group
      end
    end

    doc.inquiries.each do |inquiry|
      inquiry.state = row.inquiry_state unless row.inquiry_state.nil?
    end
  end

  def build_event(doc, row)
    doc.event_state = row.event_state
    doc.event_note = row.event_note

    attrs = doc.periods.blank? ? {} : periods_attributes_from_doc(doc)
    new_attrs = row.event_periods.blank? ? {} : periods_attributes_from_row(row)
    doc.periods_attributes = attrs.merge(new_attrs) { |k, ov, nv| ov.merge(nv) }

    categories = @event_categories.select { |category| category.title.in?(row.event_category_titles) }

    doc.event_categorizations.each do |c|
      if c.categorized_as == 'GpCalendar::Event' && !categories.include?(c.category)
        c.mark_for_destruction
      end
    end

    categories.each do |category|
      if !doc.event_categorizations.detect { |c| c.category == category && c.categorized_as == 'GpCalendar::Event' }
        doc.event_categorizations.build(category: category, categorized_as: 'GpCalendar::Event')
      end
    end
  end

  def periods_attributes_from_doc(doc)
    doc.periods.each_with_object({}).with_index do |(period, attrs), idx|
      attrs[idx] = { id: period.id, started_on: nil, ended_on: nil }
    end
  end

  def periods_attributes_from_row(row)
    row.event_periods.each_with_object({}).with_index do |(period, attrs), idx|
      attrs[idx] = { started_on: period[0], ended_on: period[1] }
    end
  end

  def build_categories(doc, row)
    categories = @category_types.keys.each_with_object([]) do |title, categories|
                   category_titles = row.category_titles_from_category_type_title(title)
                   next if category_titles.blank?
                   if @content.category_relation_type == 0
                    cs = @category_types[title].select { |category| category.name.in?(category_titles) }
                   else
                    cs = @category_types[title].select { |category| category.title.in?(category_titles) }
                   end
                   categories.concat(cs) if cs.present?
                 end
    row.category_titles = categories.pluck(:title)

    doc.categorizations.each do |c|
      if c.categorized_as == 'GpArticle::Doc' && !categories.include?(c.category)
        c.mark_for_destruction
      end
    end

    categories.each do |category|
      if !doc.categorizations.detect { |c| c.category == category && c.categorized_as == 'GpArticle::Doc' }
        doc.categorizations.build(category: category, categorized_as: 'GpArticle::Doc')
      end
    end
  end

  def build_categories_from_regexp(doc, row)
    category_type_id = doc&.content&.category_types&.pluck(:id)
    category_id_relation = @content.category_id_dictionary
    category_column_regexp = @content.setting.category_column_regexp
    category_ids = row.data.headers.each_with_object([]) do |key, category_ids|
      next if key !~ /#{category_column_regexp}/
      if category_id_relation.present? && rel = category_id_relation[row.data[key]]
        category_type_id = doc&.content&.category_types&.where(name: rel[0])&.pluck(:id) if rel[0].present?
        category_ids.concat(rel[1]) if rel[1].present?
      else
        category_ids << row.data[key]
      end
    end
    categories = GpCategory::Category.where(category_type_id: category_type_id, name: category_ids)
    row.category_titles = categories.pluck(:title)

    doc.categorizations.each do |c|
      if c.categorized_as == 'GpArticle::Doc' && !categories.include?(c.category)
        c.mark_for_destruction
      end
    end

    categories.each do |category|
      if !doc.categorizations.detect { |c| c.category == category && c.categorized_as == 'GpArticle::Doc' }
        doc.categorizations.build(category: category, categorized_as: 'GpArticle::Doc')
      end
    end

  end

  def build_categories_in_import(doc, row)
    categories = @category_types.keys.each_with_object([]) do |title, categories|
                   category_titles = row.category_titles_from_category_type_dictionary(title)
                   next if category_titles.blank?
                   cs = @category_types[title].select { |category| category.title.in?(category_titles) }
                   categories.concat(cs) if cs.present?
                 end
    row.category_titles = categories.pluck(:title)

    doc.categorizations.each do |c|
      if c.categorized_as == 'GpArticle::Doc' && !categories.include?(c.category)
        c.mark_for_destruction
      end
    end

    categories.each do |category|
      if !doc.categorizations.detect { |c| c.category == category && c.categorized_as == 'GpArticle::Doc' }
        doc.categorizations.build(category: category, categorized_as: 'GpArticle::Doc')
      end
    end
  end

  def build_default_categories(doc, row)
    category_type_id = doc&.content&.category_types&.pluck(:id)
    categories = GpCategory::Category.where(category_type_id: category_type_id, name: @content.default_category_ids)
    categories.each do |category|
      if !doc.categorizations.detect { |c| c.category == category && c.categorized_as == 'GpArticle::Doc' }
        doc.categorizations.build(category: category, categorized_as: 'GpArticle::Doc')
      end
    end
  end

  def build_map(doc, row)
    doc.marker_state = row.marker_state
    doc.marker_sort_no = row.marker_sort_no
    doc.navigation_state = 'enabled'

    categories = @marker_categories.select { |category| category.title.in?(row.marker_category_titles) }

    doc.marker_categorizations.each do |c|
      if c.categorized_as == 'Map::Marker' && !categories.include?(c.category)
        c.mark_for_destruction
      end
    end

    categories.each do |category|
      if !doc.marker_categorizations.detect { |c| c.category == category && c.categorized_as == 'Map::Marker' }
        doc.marker_categorizations.build(category: category, categorized_as: 'Map::Marker')
      end
    end

    category_column_regexp = @content.setting.category_column_regexp
    if category_column_regexp.present?
      category_type_id = doc&.content&.marker_category_types&.pluck(:id)
      category_id_relation = @content.map_category_id_dictionary
      category_ids = row.data.headers.each_with_object([]) do |key, category_ids|
        next if key !~ /#{category_column_regexp}/
        if category_id_relation.present? && rel = category_id_relation[row.data[key]]
          category_type_id = doc&.content&.marker_category_types&.where(name: rel[0])&.pluck(:id) if rel[0].present?
          category_ids.concat(rel[1]) if rel[1].present?
        else
          category_ids << row.data[key]
        end
      end
      categories = GpCategory::Category.where(category_type_id: category_type_id, name: category_ids)
      categories.each do |category|
        if !doc.marker_categorizations.detect { |c| c.category == category && c.categorized_as == 'Map::Marker' }
          doc.marker_categorizations.build(category: category, categorized_as: 'Map::Marker')
        end
      end
    end


    if row.map_exist?
      doc.marker_state = "visible"
      doc.maps.build if doc.maps.blank?

      map = doc.maps[0]
      map.name = '1'
      map.title = row.map_title
      map.map_lat = row.map_lat
      map.map_lng = row.map_lng
      map.map_zoom = row.map_zoom

      new_map_markers = row.map_markers
      new_map_markers.each_with_index do |(name, lat, lng), idx|
        marker = map.markers[idx] || map.markers.build
        marker.name = name
        marker.lat = lat
        marker.lng = lng
      end

      (new_map_markers.size).upto(map.markers.size - 1) do |idx|
        map.markers[idx].mark_for_destruction
      end
    else
      doc.maps.each do |map|
        map.mark_for_destruction
        map.markers.each do |marker|
          marker.mark_for_destruction
        end
      end
    end
  end

  def build_file(doc, row)
    if row.file_path.present?
      path = File.join(@content.site.public_path, row.file_path).to_s
      return unless File.exist?(path)

      doc.files.build if doc.files.blank?
      file = doc.files[0]
      file.file = ActionDispatch::TempFile.create_from_path(path)
      file.site_id = @content.site_id
      file.name = row.file_name
      file.title = row.file_title
      file.alt_text = row.file_alt_text
      file.image_resize = row.file_image_resize.presence || @dest_content.setting.attachment_resize_size
      if file.creator.blank?
        file.build_creator
        file.creator.user = doc.creator.user
        file.creator.group = doc.creator.group
      else
        file.build_editor if file.editor.blank?
        file.editor.user = doc.editor.user
        file.editor.group = doc.editor.group
      end
    else
      doc.files.each { |file| file.mark_for_destruction }
    end
  end

  def build_file_in_import(doc, row)
    if row.data[@content.setting.attachement_column].present?
      path = "#{@content.setting.attachement_directory}#{row.data[@content.setting.attachement_column]}"
      return unless File.exist?(path)
      doc.files.build if doc.files.blank?
      file = doc.files[0]
      file.file = ActionDispatch::TempFile.create_from_path(path)
      file.site_id = @content.site_id
      file.name = File.basename(row.data[@content.setting.attachement_column])
      file.title = row.title
      file.alt_text = row.title
      file.image_resize = row.file_image_resize.presence || @dest_content.setting.attachment_resize_size
      if file.creator.blank?
        file.build_creator
        file.creator.user = doc.creator.user
        file.creator.group = doc.creator.group
      else
        file.build_editor if file.editor.blank?
        file.editor.user = doc.editor.user
        file.editor.group = doc.editor.group
      end
    else
      doc.files.each { |file| file.mark_for_destruction }
    end
  end

  def build_files_from_directory(doc, row)
    file_directory = @content.setting.attachement_directory.gsub(/@data\[\"(.+?)\"]/){|s| row.data[$1] }
    if Dir.exist?(file_directory)
      Dir.glob("#{file_directory}*").each do |f|
        next if File.directory?(f)
        filename = File.basename(f)
        next if filename.blank?
        ext = File.extname(filename)
        no_ext_filename = File.basename(f, ext)
        en_filename = filename =~ /^[0-9a-zA-Z\-\s\._]*$/ && no_ext_filename !~ /\./ ? filename : "#{Time.now.strftime("%Y%m%d%H%M%S%L")}#{ext}"
        file = doc.files.where(file_attachable: doc, title: filename).first || doc.files.build(file_attachable: doc, title: filename)
        file.file = ActionDispatch::TempFile.create_from_path(f)
        file.site = @content.site
        file.name = en_filename || file.name
        file.title = filename
        file.tmp_id = doc.in_tmp_id
        file.alt_text = filename
        file.image_resize = row.file_image_resize.presence || @dest_content.setting.attachment_resize_size
        if file.creator.blank?
          file.build_creator
          file.creator.user = doc.creator.user
          file.creator.group = doc.creator.group
        else
          file.build_editor if file.editor.blank?
          file.editor.user = doc.editor.user
          file.editor.group = doc.editor.group
        end
      end
    else
      doc.files.each { |file| file.mark_for_destruction }
    end
  end

  def build_list_image(row)
    return nil if @content.setting.list_image.blank?
    list_image = @content.setting.list_image.gsub(/@data\[\"(.+?)\"]/){|s| row.data[$1] }
    list_image = list_image == '.' ? nil : list_image
  end
end
