class Docin::Content::SettingMenu < Cms::Content::SettingMenu
  has_many :fields, class_name: 'Docin::Content::SettingField', foreign_key: :menu_id

  add_item :relation do
    add_item :gp_article_relation
    add_item :gp_template_relation
  end
  add_item :columns do
  end

  add_item :import do
  end

end
