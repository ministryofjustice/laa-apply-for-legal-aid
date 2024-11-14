require "rails_helper"

RSpec.describe Providers::Means::StateBenefitForm do
  subject(:state_benefit_form) { described_class.new(params) }

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:transaction_type) { create(:transaction_type, :benefits) }
  let(:params) do
    {
      description:,
      amount:,
      frequency:,
      transaction_type_id: transaction_type.id,
    }
  end
  let(:description) { "New State Benefit" }
  let(:amount) { 123.00 }
  let(:frequency) { "weekly" }

  describe "#new" do
    subject(:state_benefit_form) { described_class.new(model:) }

    context "when there is an existing transaction" do
      let(:model) { create(:regular_transaction, transaction_type:, legal_aid_application:, description: "Test state benefit") }

      it "populates the form" do
        expect(state_benefit_form).to have_attributes(transaction_type_id: transaction_type.id,
                                                      description: "Test state benefit",
                                                      amount: model.amount,
                                                      frequency: model.frequency)
      end
    end

    context "when no previous record exists" do
      let(:model) { RegularTransaction.new(legal_aid_application:, transaction_type_id: transaction_type.id) }

      it "creates an unpopulated form" do
        expect(state_benefit_form).to have_attributes(transaction_type_id: transaction_type.id,
                                                      description: nil,
                                                      amount: nil,
                                                      frequency: nil)
      end
    end
  end

  describe "#validate" do
    subject(:validation) { state_benefit_form.valid? }

    context "when the parameters are valid" do
      it { expect(validation).to be true }
    end

    context "when a parameter is missing" do
      let(:description) { "" }

      it { expect(validation).to be false }
    end

    context "when the amount is not numeric" do
      let(:amount) { "one hundred pounds" }

      it { expect(validation).to be false }
    end

    context "when the amount is humanized monetary value" do
      let(:amount) { "£1,000" }

      it { expect(validation).to be true }
    end

    context "when the frequency is not valid" do
      let(:frequency) { "NOT-A-FREQUENCY" }

      it { expect(validation).to be false }
    end
  end

  describe "#save" do
    subject(:save_form) { described_class.new(params).save }

    context "when the parameters are valid" do
      context "and a previous transaction exists" do
        let(:model) { create(:regular_transaction, transaction_type:, legal_aid_application:, description: "Existing state benefit") }
        let(:description) { "Updated State Benefit" }

        it "amends the existing transaction" do
          params[:model] = model
          expect { save_form }.not_to change(legal_aid_application.regular_transactions, :count)
          expect(legal_aid_application.regular_transactions.first.description).to eq "Updated State Benefit"
        end
      end

      context "and no previous transaction exists" do
        let(:model) { RegularTransaction.new(legal_aid_application:, transaction_type_id: transaction_type.id) }

        it "saves the new transaction" do
          params[:model] = model
          expect { save_form }.to change(legal_aid_application.regular_transactions, :count).by(1)
          expect(legal_aid_application.regular_transactions.first.description).to eq "New State Benefit"
        end
      end

      context "with humanized monetary value" do
        let(:model) { RegularTransaction.new(legal_aid_application:, transaction_type_id: transaction_type.id) }
        let(:amount) { "£1,244.55" }

        it "saves the new transaction" do
          params[:model] = model
          save_form

          expect(legal_aid_application.regular_transactions.first.amount).to eq(1_244.55)
        end
      end
    end
  end
end
