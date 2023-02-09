RSpec.describe Docin::Parse::CsvInteractor, type: :interactor do
  describe '#call' do
    let!(:content) { create(:docin_import_content, :with_related_contents) }
    let!(:csv) { NKF.nkf('-w', File.read(Zplugin::Content::Docin::Engine.root.join('spec/fixtures/files/test.csv').to_s)) }

    it 'parses csv' do
      context = described_class.call(content: content, user: root_user, csv: csv)
      expect(context.success?).to eq(true)
      expect(context.results.size).to eq(4)
    end
  end
end
