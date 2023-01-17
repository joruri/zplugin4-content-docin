class Docin::BuildService < ApplicationService
  def initialize(content, user)
    @content = content
    @user = user

    @dest_content = @content.gp_article_content
    @category_types = @dest_content.category_types.map do |category_type|
                        [category_type.title, category_type.categories]
                      end.to_h

    @body_template = Erubis::Eruby.new(@content.body_template)
    @summary_template = Erubis::Eruby.new(@content.summary_template)
  end

  def build(row, doc: nil)
    doc ||= @dest_content.docs.where(name: row.name).first_or_initialize

    doc.state = row.state
    doc.title = row.title
    doc.body = @body_template.evaluate(data: row.data)
    doc.summary = @summary_template.evaluate(data: row.data)
    doc.concept = @dest_content.concept
    doc.display_updated_at = Time.now
    doc.display_published_at ||= Time.now
    doc.recognized_at = Time.now
    doc.qrcode_state = 'visible'
    doc.marker_state = 'visible'
    doc.marker_sort_no = row.marker_sort_no
    doc.navigation_state = 'enabled'

    # creator editor
    if doc.creator.blank?
      doc.build_creator
      doc.creator.user = @user
      doc.creator.group = @user.group
    else
      doc.build_editor if doc.editor.blank?
      doc.editor.user = @user
      doc.editor.group = @user.group
    end

    # map
    build_map(doc, row)

    # category
    build_categories(doc, row)

    doc.in_ignore_accessibility_check = '1'
    doc.in_ignore_link_check = '1'

    doc
  end

  private

  def build_categories(doc, row)
    categories = @category_types.keys.each_with_object([]) do |title, categories|
                   category_title = row.category_title(title)
                   next if category_title.blank?
                   category = @category_types[title].find { |category| category.title == category_title }
                   categories << category if category.present?
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

  def build_map(doc, row)
    doc.maps.build if doc.maps.blank?

    map = doc.maps[0]
    map.name = '1'
    map.map_lat = row.map_lat
    map.map_lng = row.map_lng
    map.map_zoom = 14

    marker = map.markers[0] || map.markers.build
    marker.name = row.title
    marker.lat = row.map_lat
    marker.lng = row.map_lng
  end
end
