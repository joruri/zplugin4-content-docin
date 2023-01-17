FactoryBot.define do
  factory :docin_import_content, class: 'Docin::Content::Import' do
    site_id { 1 }
    concept_id { 1 }
    name { "記事取込" }
    code { "docin_import_test" }
    model { "Docin::Import" }

    trait :with_related_contents do
      after(:create) do |item|
        gp_article_content = FactoryBot.create(:gp_article_content, :with_related_contents)
        item.setting.gp_article_content_id = gp_article_content.id
        item.setting.save
      end
    end
  end
end
