RSpec.describe Docin::Admin::ImportsController, type: :request do
  let!(:content) { FactoryBot.create(:docin_import_content) }

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

end
