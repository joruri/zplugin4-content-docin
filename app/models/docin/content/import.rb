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

  def auto_publisher?
    setting.auto_publisher == 1
  end

  def default_category_ids
    return [] if setting.default_category_id.blank?
    setting.default_category_id.split(/\|/)
  end

  def export_csv_path
    site_dir = site ? "sites/#{format('%04d', site.id)}" : "."
    md_dir  = self.class.to_s.underscore.pluralize
    id_dir  = format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    id_file = format('%07d', id)
    id_file += '.dat'
    Rails.root.join("#{site_dir}/upload/#{md_dir}/#{id_dir}/#{id_file}").to_s
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

  def category_id_dictionary
    mapping = {}
    return mapping if setting.category_id_relation.blank?
    setting.category_id_relation.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = {} if mapping[data[0].strip].blank?
        ids = data[2].present? ? data[2].split(/\|/) : []
        mapping[data[0].strip] = [data[1].strip, ids]
      else
        next
      end
    end
    mapping
  end

  def map_category_id_dictionary
    mapping = {}
    return mapping if setting.map_category_id_relation.blank?
    setting.map_category_id_relation.split(/\r\n|\n/).each do |line|
      if line =~ /,/
        data = line.split(/,/)
        mapping[data[0].strip] = {} if mapping[data[0].strip].blank?
        ids = data[2].present? ? data[2].split(/\|/) : []
        mapping[data[0].strip] = [data[1].strip, ids]
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
