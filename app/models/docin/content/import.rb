class Docin::Content::Import < Cms::Content
  default_scope { where(model: 'Docin::Import') }

  has_one :setting, foreign_key: :content_id, class_name: 'Docin::Content::Setting', dependent: :destroy
  delegate_attr_json_for :setting

  has_one :log, class_name: 'Zplugin::Content::Docin::Log', foreign_key: :content_id, dependent: :destroy

  def gp_article_content
    setting.gp_article_content
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

  def attachement_directory_import?
    setting.attachement_directory_import == 1
  end

  def daily_import?
    setting.daily_import == 1
  end

  def auto_closure?
    setting.auto_closure == 1
  end

  def org_dictionary
    mapping = {}
    return {} if setting.org_relation.blank?
    setting.org_relation.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = data[1].strip
      else
        next
      end
    end
    mapping
  end

  def quota_content_dictionary
    mapping = {}
    return {} if setting.quota_dictionary.blank?
    setting.quota_dictionary.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = data[1].strip
      else
        next
      end
    end
    mapping
  end

  def status_dictionary
    mapping = {}
    return {} if setting.status_relation.blank?
    setting.status_relation.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = data[1].strip
      else
        next
      end
    end
    mapping
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
