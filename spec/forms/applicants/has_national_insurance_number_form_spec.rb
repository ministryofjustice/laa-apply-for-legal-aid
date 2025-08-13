require "rails_helper"

RSpec.describe Applicants::HasNationalInsuranceNumberForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:applicant) { create(:applicant, has_national_insurance_number: nil, national_insurance_number: nil) }
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }

  let(:params) do
    {
      has_national_insurance_number:,
      model: applicant,
    }
  end

  describe ".model_name" do
    it 'is "Applicant"' do
      expect(described_class.model_name).to eq("Applicant")
    end
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with yes chosen and valid national insurance number provided" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "JA123456D" } }

      it "updates has_national_insurance_number and national_insurance_number" do
        expect { call_save }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(has_national_insurance_number: nil, national_insurance_number: nil))
          .to(hash_including(has_national_insurance_number: true, national_insurance_number: "JA123456D"))
      end
    end

    context "with yes chosen and valid national insurance number provided with bad formatting" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: " ja 123 456 d " } }

      it "updates national_insurance_number with normalised/converted value" do
        expect { call_save }.to change(applicant, :national_insurance_number).from(nil).to("JA123456D")
      end
    end

    context "with yes chosen and national insurance number NOT provided" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom blank error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Enter a National Insurance number")
      end
    end

    context "with yes chosen and invalid national insurance number provided" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "foobar" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom invalid error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Enter a valid National Insurance number")
      end
    end

    context "with yes chosen and invalid national insurance number with valid format" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "AA123456K" } }

      before { call_save }

      it { expect(instance).not_to be_valid }

      it "adds custom invalid error message" do
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Enter a valid National Insurance number")
      end
    end

    context "with yes chosen and a known invalid test national insurance number provided" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "JS130161E" } }

      before do
        allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth).and_return(in_test_mode)
        call_save
      end

      context "when configured to use mock entra id login" do
        let(:in_test_mode) { "true" }

        it { expect(instance).to be_valid, "was invalid with errors: #{instance.errors.messages}" }
      end

      context "when configured to use real entra id login" do
        let(:in_test_mode) { "false" }

        it { expect(instance).not_to be_valid }

        it "adds custom invalid error message" do
          error_messages = instance.errors.messages.values.flatten
          expect(error_messages).to include("Enter a valid National Insurance number")
        end
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, has_national_insurance_number: "false" } }

      context "when no answer previously chosen" do
        before { applicant.update!(has_national_insurance_number: nil, national_insurance_number: nil) }

        it "updates has_national_insurance_number and national_insurance_number" do
          expect { call_save }.to change { applicant.attributes.symbolize_keys }
            .from(hash_including(has_national_insurance_number: nil, national_insurance_number: nil))
            .to(hash_including(has_national_insurance_number: false, national_insurance_number: nil))
        end
      end

      context "when yes previously chosen" do
        before { applicant.update!(has_national_insurance_number: true, national_insurance_number: "JA123456D") }

        it "updates has_national_insurance_number to false" do
          expect { call_save }.to change(applicant, :has_national_insurance_number).from(true).to(false)
        end

        it "updates national_insurance_number to nil" do
          expect { call_save }.to change(applicant, :national_insurance_number).from("JA123456D").to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:params) { { has_national_insurance_number: "", model: applicant } }

      it "is invalid" do
        call_save
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        call_save
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if the client has a National Insurance number")
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with yes chosen and valid national insurance number provided" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "JA123456D" } }

      it "updates has_national_insurance_number and national_insurance_number" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(has_national_insurance_number: nil, national_insurance_number: nil))
          .to(hash_including(has_national_insurance_number: true, national_insurance_number: "JA123456D"))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with yes chosen and national insurance number NOT provided" do
      let(:params) { { model: applicant, has_national_insurance_number: "true", national_insurance_number: "" } }

      it "updates has_national_insurance_number and national_insurance_number" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(has_national_insurance_number: nil, national_insurance_number: nil))
          .to(hash_including(has_national_insurance_number: true, national_insurance_number: nil))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with no chosen" do
      let(:params) { { model: applicant, has_national_insurance_number: "false" } }

      it "updates has_national_insurance_number and national_insurance_number" do
        expect { save_as_draft }.to change { applicant.attributes.symbolize_keys }
          .from(hash_including(has_national_insurance_number: nil, national_insurance_number: nil))
          .to(hash_including(has_national_insurance_number: false, national_insurance_number: nil))
      end

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end

    context "with no answer chosen" do
      let(:params) { { model: applicant, has_national_insurance_number: "" } }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end
    end
  end
end
