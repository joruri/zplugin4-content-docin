RSpec.describe Docin::Admin::Content::SettingsController, type: :request do
  let!(:content) { FactoryBot.create(:docin_import_content, :with_related_contents) }

  before do
    login root_user
    get docin_content_settings_path(content: content, concept: content.concept)
  end

  describe '#index' do
    it 'gets response' do
      get docin_content_settings_path
      expect(response.status).to eq(200)
    end
  end

  Docin::Content::SettingMenu.all.each do |menu|
    context menu.id do
      describe '#show' do
        it 'gets response' do
          get docin_content_setting_path(id: menu.id)
          expect(response.status).to eq(200)
        end
      end

      describe '#edit' do
        it 'gets response' do
          get edit_docin_content_setting_path(id: menu.id)
          expect(response.status).to eq(200)
        end
      end

      describe '#update' do
        it 'gets response' do
          patch docin_content_setting_path(id: menu.id), params: { item: content.setting.data }
          expect(response.status).to eq(302)
        end
      end
    end
  end
end
