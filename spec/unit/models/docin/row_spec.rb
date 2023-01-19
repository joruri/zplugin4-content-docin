RSpec.describe Docin::Row, type: :model do
  describe '#event_periods' do
    context 'single' do
      it 'gets periods' do
        data = { 'イベント期間' => '2023-01-23～2023-01-27' }
        row = described_class.new(data: data)
        expect(row.event_periods).to match([[Date.parse('2023-01-23'), Date.parse('2023-01-27')]])
      end
    end

    context 'multiple' do
      it 'gets periods' do
        data = { 'イベント期間' => "2023-01-23～2023-01-27\n2023-01-30～2023-01-31" }
        row = described_class.new(data: data)
        expect(row.event_periods).to match(
          [[Date.parse('2023-01-23'), Date.parse('2023-01-27')],
           [Date.parse('2023-01-30'), Date.parse('2023-01-31')]]
        )
      end
    end

    context 'only started date' do
      it 'gets periods' do
        data = { 'イベント期間' => "2023-01-23" }
        row = described_class.new(data: data)
        expect(row.event_periods).to match([[Date.parse('2023-01-23'), Date.parse('2023-01-23')]])
      end
    end

    context 'only ended date' do
      it 'gets periods' do
        data = { 'イベント期間' => "～2023-01-27" }
        row = described_class.new(data: data)
        expect(row.event_periods).to match([[Date.parse('2023-01-27'), Date.parse('2023-01-27')]])
      end
    end

    context 'invalid date' do
      it 'gets periods' do
        data = { 'イベント期間' => "2023-01～2023-01-27\nABCDE" }
        row = described_class.new(data: data)
        expect(row.event_periods).to match([[Date.parse('2023-01-27'), Date.parse('2023-01-27')]])
      end
    end
  end
end
