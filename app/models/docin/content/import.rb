class Docin::Content::Import < Cms::Content
  default_scope { where(model: 'Docin::Import') }

  has_one :setting, foreign_key: :content_id, class_name: 'Docin::Content::Setting', dependent: :destroy
  delegate_attr_json_for :setting

  def enable_marker?
    setting.enable_marker == 1
  end

  def gp_article_content
    setting.gp_article_content
  end

  def data_text
    setting.data_text
  end

  def body_template
    setting.body_template.to_s
  end

  def summary_template
    setting.summary_template.to_s
  end

  def import_creator_user
    Sys::User.find_by(id: setting.import_user_id)
  end

  def doc_name_prefix
    return @doc_name_prefix if @doc_name_prefix.present?
    @doc_name_prefix = setting.doc_name_prefix
    @doc_name_prefix
  end

  def skip_close
    setting.skip_close == 'enabled'
  end

  def skip_category
    return @skip_category if @skip_category.present?
    @skip_category = {}
    return {} if setting.skip_category.blank?
    setting.skip_category.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        @skip_category[data[0].strip] = [] if @skip_category[data[0].strip].blank?
        @skip_category[data[0].strip] << data[1].strip
      else
        next
      end
    end
    @skip_category
  end

  def close_category
    return @close_category if @close_category.present?
    @close_category = {}
    return {} if setting.close_category.blank?
    setting.close_category.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        @close_category[data[0].strip] = [] if @close_category[data[0].strip].blank?
        @close_category[data[0].strip] << data[1].strip
      else
        next
      end
    end
    @close_category
  end

  def column_replace_dictionary
    mapping = {}
    return mapping if setting.column_replace.blank?
    setting.column_replace.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = {} if mapping[data[0].strip].blank?
        mapping[data[0].strip][data[1].strip] = data[2].strip
      else
        next
      end
    end
    mapping
  end

  def category_type_dictionary
    mapping = {}
    return {} if setting.category_relation.blank?
    setting.category_relation.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = data[1].strip
      else
        next
      end
    end
    mapping
  end

end
