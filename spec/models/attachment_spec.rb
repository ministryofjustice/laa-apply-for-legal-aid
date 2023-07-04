require "rails_helper"

RSpec.describe Attachment do
  let!(:soc1) { create(:attachment) }
  let!(:soc2) { create(:attachment) }
  let!(:merits1) { create(:attachment, :merits_report) }
  let!(:merits2) { create(:attachment, :merits_report) }
  let!(:means1) { create(:attachment, :means_report) }
  let!(:bank) { create(:attachment, :bank_transaction_report) }

  context "with scopes" do
    it "returns the expected collections" do
      expect(described_class.statement_of_case).to contain_exactly(soc1, soc2)
      expect(described_class.merits_report).to contain_exactly(merits1, merits2)
      expect(described_class.means_report).to eq [means1]
      expect(described_class.bank_transaction_report).to eq [bank]
    end
  end
end
