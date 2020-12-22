FactoryBot.define do
  factory :doc_import_file, class: 'Docin::Row' do
    file_path = Zplugin::Content::Docin::Engine.root.join('spec/fixtures/files/test.csv').to_s
    file { fixture_file_upload(file_path, 'text/csv') }
  end 

  factory :doc_import_row, class: 'Docin::Row' do
    file_path = Zplugin::Content::Docin::Engine.root.join('spec/fixtures/files/test.csv').to_s
    import_csv = NKF.nkf('-w', File.read(file_path))
    csv { import_csv }
  end 
end
