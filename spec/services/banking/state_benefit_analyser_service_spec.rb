require "rails_helper"

RSpec.describe Banking::StateBenefitAnalyserService do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:applicant) { create(:applicant, legal_aid_application:, national_insurance_number: nino) }
  let(:bank_provider) { create(:bank_provider, applicant:) }
  let(:bank_account1) { create(:bank_account, bank_provider:) }
  let(:nino) { "YS327299B" }
  let!(:included_benefit_transaction_type) { create(:transaction_type, :benefits) }

  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application) }

    before do
      allow(CFECivil::ObtainStateBenefitTypesService).to receive(:call).and_return(dummy_benefits)
    end

    context "when there are no state benefit transactions" do
      let!(:transactions) { create_mix_of_non_benefit_transactions }

      it "does not change any bank transactions" do
        call
        expect(legal_aid_application.reload.bank_transactions.order(:id)).to eq transactions
      end

      it "does not add any transaction types to the legal aid application" do
        expect { call }.not_to change { legal_aid_application.transaction_types.count }
      end
    end

    context "when the DWP payment is for a different nino" do
      before do
        create_list(:bank_transaction, 1, :credit, description: "DWP YS327299X UC", bank_account: bank_account1)
        call
      end

      let(:tx) { legal_aid_application.reload.bank_transactions.first }

      it "marks the transaction as a state benefit" do
        expect(tx.transaction_type_id).to eq included_benefit_transaction_type.id
      end

      # OCT-2020: A choice has been made that, for now, we should not try to untangle NINO mismatches.
      # We are just interested in the fact they can access the income
      it "updates the meta data with the label of the state benefit" do
        expect(tx.meta_data).to eq({ code: "UC", label: "universal_credit", name: "Universal Credit", selected_by: "System" })
      end
    end

    context "when the DWP payment for this applicant has a recognised code" do
      context "and it's an included benefit" do
        before { create_list(:bank_transaction, 1, :credit, description: "010101010101-CHB", bank_account: bank_account1) }

        it "marks the transaction as a state benefit" do
          call
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.transaction_type_id).to eq included_benefit_transaction_type.id
        end

        it "updates the meta data with the label of the state benefit" do
          call
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.meta_data).to eq({ code: "CHB", label: "child_benefit", name: "Child Benefit", selected_by: "System" })
        end

        it "adds included transaction types to the legal aid application" do
          expect(legal_aid_application.transaction_types.count).to be_zero
          call
          expect(legal_aid_application.transaction_types).to include(included_benefit_transaction_type)
        end
      end

      context "and it's a child benefit under a new code HMRC CHILD BENEFIT" do
        before do
          create_list(:bank_transaction, 1, :credit, description: "HMRC CHILD BENEFIT", bank_account: bank_account1)
          call
        end

        it "marks the transaction as a state benefit" do
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.transaction_type_id).to eq included_benefit_transaction_type.id
        end

        it "updates the meta data with the label of the state benefit" do
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.meta_data).to eq({ code: "HMRC CHILD BENEFIT", label: "hmrc_child_benefit", name: "Child Benefit", selected_by: "System" })
        end
      end

      context "and it's an excluded/disregarded benefit" do
        before { create_list(:bank_transaction, 1, :credit, description: "DWP #{nino} DLA", bank_account: bank_account1) }

        it "does not mark the transaction as a state benefit" do
          call
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.transaction_type_id).to be_nil
        end

        it "does not update the meta data with the label of the state benefit" do
          call
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.meta_data).to be_nil
        end

        it "adds included transaction types to the legal aid application" do
          expect(legal_aid_application.transaction_types.count).to be_zero
          call

          expect(legal_aid_application.transaction_types).to include(included_benefit_transaction_type)
        end
      end

      context "and it's a an included benefit whose DWP code requires escaping" do
        before { create_list(:bank_transaction, 1, :credit, description: "0101010 T/P", bank_account: bank_account1) }

        it "marks the transaction as a state benefit" do
          call
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.transaction_type_id).to eq included_benefit_transaction_type.id
        end

        it "updates the meta data with the label of the state benefit" do
          call
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.meta_data).to eq({ code: "T/P", label: "training_payment", name: "Training Payment", selected_by: "System" })
        end

        it "adds included transaction types to the legal aid application" do
          expect(legal_aid_application.transaction_types.count).to be_zero
          call
          expect(legal_aid_application.transaction_types).to include(included_benefit_transaction_type)
        end
      end
    end

    context "when the DWP payment for this applicant has multiple recognised codes" do
      context "and there is an included benefit" do
        before do
          create_list(:bank_transaction, 1, :credit, description: "DWP DP JSA MID CWP #{nino} DWP UC 10203040506070809N", bank_account: bank_account1)
          call
        end

        # OCT-2020: A choice has been made that, for now, we should not try to handle multiple codes in a single row.These
        # should be flagged by CFE and marked for case worker review. They can still be marked as benefits by the provider
        it "does not update the meta data" do
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.meta_data).to eq({ code: "multiple", label: "multiple dwp codes", name: "multiple state benefits", selected_by: "System" })
        end

        it "adds a caseworker flag for multi_benefit" do
          expect(legal_aid_application.reload.bank_transactions.first.flags["multi_benefit"]).to be true
        end
      end

      context "and there are duplicate benefits" do
        before do
          create_list(:bank_transaction, 1, :credit, description: "123456789999-CHB BGC 123456789999-CHB BGC", bank_account: bank_account1)
          call
        end

        it "updates the meta data" do
          tx = legal_aid_application.reload.bank_transactions.first
          expect(tx.meta_data).to eq({ code: "CHB", label: "child_benefit", name: "Child Benefit", selected_by: "System" })
        end

        it "does not add a caseworker flag for multi_benefit" do
          expect(legal_aid_application.reload.bank_transactions.first.flags).to be_nil
        end
      end
    end

    def dummy_benefits
      [
        {
          "label" => "cold_weather_payment",
          "name" => "Cold Weather Payment",
          "dwp_code" => "CWP",
          "exclude_from_gross_income" => false,
          "category" => nil,
          "selected_by" => "System",
        },
        {
          "label" => "child_benefit",
          "name" => "Child Benefit",
          "dwp_code" => "CHB",
          "exclude_from_gross_income" => false,
          "category" => nil,
          "selected_by" => "System",
        },
        {
          "label" => "hmrc_child_benefit",
          "name" => "Child Benefit",
          "dwp_code" => "HMRC CHILD BENEFIT",
          "exclude_from_gross_income" => false,
          "category" => nil,
          "selected_by" => "System",
        },
        {
          "label" => "universal_credit",
          "name" => "Universal Credit",
          "exclude_from_gross_income" => false,
          "dwp_code" => "UC",
          "category" => nil,
          "selected_by" => "System",
        },
        {
          "label" => "disability_living_allowance",
          "name" => "Disability Living Allowance",
          "dwp_code" => "DLA",
          "exclude_from_gross_income" => true,
          "category" => "carer_disability",
          "selected_by" => "System",
        },
        {
          "label" => "employment_support_allowance",
          "name" => "Employment Support Allowance",
          "dwp_code" => "ESA",
          "exclude_from_gross_income" => false,
          "category" => nil,
          "selected_by" => "System",
        },
        {
          "label" => "training_payment",
          "name" => "Training Payment",
          "dwp_code" => "T/P",
          "exclude_from_gross_income" => false,
          "category" => nil,
          "selected_by" => "System",
        },
        {
          "label" => "social_fund_payments",
          "name" => "Social Fund Payment",
          "dwp_code" => nil,
          "exclude_from_gross_income" => false,
          "category" => nil,
          "selected_by" => "System",
        },
      ]
    end

    def create_mix_of_non_benefit_transactions
      transactions = create_list(:bank_transaction, 3, bank_account: bank_account1)
      transactions.sort_by(&:id)
    end
  end
end
