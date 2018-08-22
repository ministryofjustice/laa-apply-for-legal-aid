require 'rails_helper'

RSpec.describe Healthcheck, type: :service do
  describe '.perform' do
    it 'returns an hash with the healthy status' do
      result = described_class.perform
      expect(result).to eq(database: true)
    end

    context 'when the database is not healthy' do
      let(:mocked_connection) { double(:active_record_connection) }

      it 'returns an hash with the unhealthy status' do
        expect(ActiveRecord::Base).to receive(:connection).and_return(mocked_connection)
        expect(mocked_connection).to receive(:active?).and_raise(PG::ConnectionBad)

        result = described_class.perform
        expect(result).to eq(database: false)
      end
    end
  end
end
