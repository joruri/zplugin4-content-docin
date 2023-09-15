RSpec.describe Docin::Admin::ImportsController, type: :request do
  let!(:content) { create(:docin_import_content, :with_related_contents) }
  let!(:image_src_path) { Zplugin::Content::Docin::Engine.root.join('spec/fixtures/files/image.png').to_s }
  let!(:image_dest_path) { File.join(content.site.public_path, '/docin-files-test/image.png').to_s }

  before do
    login root_user
    get docin_imports_path(content: content, concept: content.concept)

    FileUtils.mkdir_p(File.dirname(image_dest_path)) unless Dir.exist?(File.dirname(image_dest_path))
    FileUtils.cp(image_src_path, image_dest_path)
  end

  after do
    FileUtils.rm_rf(File.dirname(image_dest_path)) if Dir.exist?(File.dirname(image_dest_path))
  end

  describe '#index' do
    it 'gets response' do
      get docin_imports_path
      expect(response.status).to eq(200)
    end
  end

  describe '#confirm' do
    it 'gets response' do
      post docin_imports_path(content: content, concept: content.concept),
        params: { confirm: 'do', item: attributes_for(:doc_import_file) }
      expect(response.status).to eq(200)
    end
  end

  describe '#register' do
    it 'gets response' do
      post docin_imports_path(content: content, concept: content.concept),
        params: { register: 'do', item: attributes_for(:doc_import_row) }
      expect(response.status).to eq(302)
    end
  end
end
