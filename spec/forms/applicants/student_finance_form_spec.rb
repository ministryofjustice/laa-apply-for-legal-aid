require "rails_helper"

RSpec.describe Applicants::StudentFinanceForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant, student_finance: nil, student_finance_amount: nil) }
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }

  describe ".model_name" do
    it 'is "Applicant"' do
      expect(described_class.model_name).to eq("Applicant")
    end
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with yes chosen and valid amount provided" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "1001.11" } }

      it "updates student_finance and student_finance_amount" do
        expect { call_save }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(student_finance: nil, student_finance_amount: nil))
          .to(hash_including(student_finance: true, student_finance_amount: 1_001.11))
      end
    end

    context "with yes chosen and amount NOT provided" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Student loan amount must be an amount of money, like 10,000")
      end
    end

    context "with yes chosen and valid number provided with too many decimals" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "1001.123" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom too many decimals error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Student loan amount must be an amount of money, like 10,000")
      end
    end

    context "with yes chosen and amount with invalid chars" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "foobar" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom invalid error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Student loan amount must be an amount of money, like 10,000")
      end
    end

    context "with yes chosen and negative amount" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "-1001.11" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom invalid error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Student loan amount must be an amount of money, like 10,000")
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, student_finance: "false" } }

      context "when no answer previously chosen" do
        before { applicant.update!(student_finance: nil, student_finance_amount: nil) }

        it "updates student_finance and student_finance_amount" do
          expect { call_save }.to change { applicant.attributes.symbolize_keys }
            .from(hash_including(student_finance: nil, student_finance_amount: nil))
            .to(hash_including(student_finance: false, student_finance_amount: nil))
        end
      end

      context "when yes previously chosen" do
        before { applicant.update!(student_finance: true, student_finance_amount: 1_001.11) }

        it "updates student_finance to false" do
          expect { call_save }.to change(applicant, :student_finance).from(true).to(false)
        end

        it "updates student_finance_amount to nil" do
          expect { call_save }.to change(applicant, :student_finance_amount).from(1_001.11).to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:params) { { student_finance: "", model: applicant } }

      it "is invalid" do
        call_save
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        call_save
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if your client receives student finance")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with yes chosen and valid amount provided" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "1001.11" } }

      it "updates student_finance and student_finance_amount" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(student_finance: nil, student_finance_amount: nil))
          .to(hash_including(student_finance: true, student_finance_amount: 1_001.11))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with yes chosen and amount NOT provided" do
      let(:params) { { model: applicant, student_finance: "true", student_finance_amount: "" } }

      it "updates student_finance and student_finance_amount" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(student_finance: nil, student_finance_amount: nil))
          .to(hash_including(student_finance: true, student_finance_amount: nil))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, student_finance: "false" } }

      context "when no answer previously chosen" do
        before { applicant.update!(student_finance: nil, student_finance_amount: nil) }

        it "updates student_finance and student_finance_amount" do
          expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
            .from(hash_including(student_finance: nil, student_finance_amount: nil))
            .to(hash_including(student_finance: false, student_finance_amount: nil))
        end
      end

      context "when yes previously chosen" do
        before { applicant.update!(student_finance: true, student_finance_amount: 1_001.11) }

        it "updates student_finance to false" do
          expect { save_as_draft }.to change(applicant, :student_finance).from(true).to(false)
        end

        it "updates student_finance_amount to nil" do
          expect { save_as_draft }.to change(applicant, :student_finance_amount).from(1_001.11).to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:params) { { model: applicant, student_finance: "" } }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end
  end
end