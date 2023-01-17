RSpec.describe Docin::Admin::ImportsController, type: :request do
  let!(:content) { FactoryBot.create(:docin_import_content, :with_related_contents) }

  before do
    login root_user
    get docin_imports_path(content: content, concept: content.concept)
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
        params: { confirm: 'do', item: FactoryBot.attributes_for(:doc_import_file) }
      expect(response.status).to eq(200)
    end
  end

  describe '#register' do
    it 'gets response' do
      post docin_imports_path(content: content, concept: content.concept),
        params: { register: 'do', item: FactoryBot.attributes_for(:doc_import_row) }
      expect(response.status).to eq(302)
    end
  end
end
