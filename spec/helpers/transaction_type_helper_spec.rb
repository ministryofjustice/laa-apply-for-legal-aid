require "rails_helper"

RSpec.describe TransactionTypeHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:owner_type) { "Applicant" }

  describe "#answer_for_transaction_type" do
    subject do
      transaction_type = instance_double(TransactionType, id: "a-stubbed-uuid")

      helper.answer_for_transaction_type(legal_aid_application:,
                                         transaction_type:,
                                         owner_type:)
    end

    context "when on bank statement upload journey" do
      before do
        allow(legal_aid_application).to receive(:client_uploading_bank_statements?).and_return(true)
      end

      context "with transaction types with positive amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 1)
        end

        it { is_expected.to eql("Yes") }
      end

      context "with transaction types with zero amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 0)
        end

        it { is_expected.to eql("Yes") }
      end

      context "without transaction types" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: false, transactions_total_by_category: "irrelevant-but-stub-needed")
        end

        it { is_expected.to eql("None") }
      end
    end

    context "when not on bank statement upload journey" do
      before do
        allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false)
      end

      context "with transaction types with positive amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 123.45)
        end

        it { is_expected.to eql("£123.45") }
      end

      context "with transaction types with zero amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 0)
        end

        it { is_expected.to eql("Yes, but none specified") }
      end

      context "without transaction types" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: false, transactions_total_by_category: "irrelevant-but-stub-needed")
        end

        it { is_expected.to eql("None") }
      end
    end
  end

  describe "#regular_transaction_answer_by_type" do
    subject do
      helper.regular_transaction_answer_by_type(legal_aid_application:,
                                                transaction_type: benefits,
                                                owner_type: "Applicant")
    end

    let(:benefits) { create(:transaction_type, :benefits) }

    context "when regular transactions exist" do
      before do
        create(:regular_transaction,
               legal_aid_application:,
               transaction_type: benefits,
               owner_type: "Applicant",
               amount: 250,
               frequency: "weekly")
      end

      it { is_expected.to eq(["£250.00", "Every week"]) }
    end

    context "when no regular transactions exist" do
      it { is_expected.to eql("None") }
    end
  end
end
