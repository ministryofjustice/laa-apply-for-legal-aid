require "rails_helper"

RSpec.describe TransactionTypeHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#answer_for_transaction_type" do
    subject do
      transaction_type = instance_double(TransactionType, id: "a-stubbed-uuid")
      helper.answer_for_transaction_type(legal_aid_application:,
                                         transaction_type:)
    end

    context "when on bank statement upload journey" do
      before do
        allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true)
      end

      context "with transaction types with positive amounts" do
        before do
          allow(legal_aid_application).to receive(:has_transaction_type?).and_return(true)
          allow(legal_aid_application).to receive(:transactions_total_by_category).and_return(1)
        end

        it { is_expected.to eql("Yes") }
      end

      context "with transaction types with zero amounts" do
        before do
          allow(legal_aid_application).to receive(:has_transaction_type?).and_return(true)
          allow(legal_aid_application).to receive(:transactions_total_by_category).and_return(0)
        end

        it { is_expected.to eql("Yes") }
      end

      context "without transaction types" do
        before do
          allow(legal_aid_application).to receive(:has_transaction_type?).and_return(false)
          allow(legal_aid_application).to receive(:transactions_total_by_category).and_return("irrelevant-but-stub-needed")
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
          allow(legal_aid_application).to receive(:has_transaction_type?).and_return(true)
          allow(legal_aid_application).to receive(:transactions_total_by_category).and_return(123.45)
        end

        it { is_expected.to eql("£123.45") }
      end

      context "with transaction types with zero amounts" do
        before do
          allow(legal_aid_application).to receive(:has_transaction_type?).and_return(true)
          allow(legal_aid_application).to receive(:transactions_total_by_category).and_return(0)
        end

        it { is_expected.to eql("Yes, but none specified") }
      end

      context "without transaction types" do
        before do
          allow(legal_aid_application).to receive(:has_transaction_type?).and_return(false)
          allow(legal_aid_application).to receive(:transactions_total_by_category).and_return("irrelevant-but-stub-needed")
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
