FactoryBot.define do
  factory :docin_import_content, class: 'Docin::Content::Import' do
    site_id { 1 }
    concept_id { 1 }
    name { "記事取込" }
    code { "docin_import_test" }
    model { "Docin::Import" }
  end
end
