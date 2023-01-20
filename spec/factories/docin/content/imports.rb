FactoryBot.define do
  factory :docin_import_content, class: 'Docin::Content::Import' do
    site_id { 1 }
    concept_id { 1 }
    name { "記事取込" }
    code { "docin_import_test" }
    model { "Docin::Import" }

    trait :with_related_contents do
      after(:create) do |item|
        gp_article_content = create(:gp_article_content, :with_related_contents)
        gp_template_content = create(:gp_template_content)
        template = create(:gp_template_template, :with_items, content: gp_template_content)
        gp_article_content.setting.gp_template_content_template_id = gp_template_content.id
        gp_article_content.setting.template_ids = [template.id]
        gp_article_content.setting.default_template_id = template.id
        gp_article_content.save

        template_values = gp_article_content.setting.default_template.items.map do |item|
                            next if item.item_type == 'attachment_file_list'
                            if %(select radio_button).include?(item.item_type)
                              [item.name, item.item_options_for_select.first]
                            else
                              [item.name, "item#{item.id}"]
                            end
                          end.reject(&:blank?).to_h
        item.setting.gp_article_content_id = gp_article_content.id
        item.setting.template_values = template_values
        item.setting.save
      end
    end
  end
end
