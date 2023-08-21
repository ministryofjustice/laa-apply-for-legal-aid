require "rails_helper"

RSpec.describe CashTransaction do
  let(:application1) { create(:legal_aid_application, :with_applicant) }
  let(:application2) { create(:legal_aid_application, :with_applicant) }
  let(:benefits) { create(:transaction_type, :benefits) }
  let(:pension) { create(:transaction_type, :pension) }
  let(:benefit_transaction_array) { [] }
  let(:pension_transaction_array) { [] }

  before do
    cash_transactions_for(application1, 1)
    cash_transactions_for(application2, 2)
  end

  def cash_transactions_for(application, multiplier)
    (1..3).each do |number|
      benefits_transaction = create(:cash_transaction,
                                    transaction_type: benefits,
                                    legal_aid_application: application,
                                    owner_type: "Applicant",
                                    owner_id: application.applicant.id,
                                    transaction_date: number.month.ago,
                                    amount: 100 * multiplier,
                                    month_number: number)
      pension_transaction = create(:cash_transaction,
                                   transaction_type: pension,
                                   legal_aid_application: application,
                                   owner_type: "Applicant",
                                   owner_id: application.applicant.id,
                                   transaction_date: number.month.ago,
                                   amount: 200 * multiplier,
                                   month_number: number)
      benefit_transaction_array << benefits_transaction
      pension_transaction_array << pension_transaction
    end
  end

  describe "amounts" do
    it "returns a hash of totals for a specific application" do
      expect(described_class.amounts_for_application(application1)).to eq expected_result1
      expect(described_class.amounts_for_application(application2)).to eq expected_result2
    end
  end

  describe "scope by parent_transaction_type" do
    it "groups the transactions keyed by parent transaction type" do
      grouped_transactions = described_class.by_parent_transaction_type
      expect(grouped_transactions[pension]).to match_array pension_transaction_array
      expect(grouped_transactions[benefits]).to match_array benefit_transaction_array
    end
  end

  context "with date formatting" do
    let(:ctx) do
      create(:cash_transaction,
             legal_aid_application: application1,
             owner_type: "Applicant",
             owner_id: application1.applicant.id,
             transaction_date: Date.new(2021, 2, 2), month_number: 1)
    end

    describe ".period_start" do
      it "displays 1st day and month of transaction date" do
        expect(ctx.period_start).to eq "01 Feb"
      end
    end

    describe ".period_end" do
      it "displays last day and month of transaction date" do
        expect(ctx.period_end).to eq "28 Feb"
      end
    end
  end

  def expected_result1
    {
      "benefits" => 300,
      "pension" => 600,
    }
  end

  def expected_result2
    {
      "benefits" => 600,
      "pension" => 1200,
    }
  end
end
