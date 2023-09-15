RSpec.describe Docin::ImportJob, type: :job, perform_enqueued_jobs: true do
  describe '#perform' do
    let!(:content) { create(:docin_import_content, :with_related_contents) }
    let!(:csv) { NKF.nkf('-w', File.read(Zplugin::Content::Docin::Engine.root.join('spec/fixtures/files/test.csv').to_s)) }

    it 'performs job' do
      expect {
        described_class.perform_later(content, user: root_user, csv: csv)
      }.to change(GpArticle::Doc, :count).by(4)
      expect(described_class).to have_been_performed
    end
  end
end
