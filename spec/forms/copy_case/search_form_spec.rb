require "rails_helper"

RSpec.describe CopyCase::SearchForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:legal_aid_application) { create(:legal_aid_application) }

  let(:params) do
    {
      model: legal_aid_application,
      search_ref:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with a valid application reference" do
      let(:search_ref) { "L-TVH-U0T" }

      before { source_application }

      context "when searched for application is from the same provider" do
        let(:source_application) do
          create(:legal_aid_application,
                 application_ref: "L-TVH-U0T",
                 provider: legal_aid_application.provider)
        end

        it { is_expected.to be_truthy }

        it "assigns the copiable_case attribute to the source application" do
          expect { call_save }.to change(instance, :copiable_case)
            .from(nil)
            .to(source_application)
        end

        it "stores the copy_case_id" do
          expect { call_save }.to change { legal_aid_application.reload.copy_case_id }
            .from(nil)
            .to(source_application.id)
        end
      end

      context "when searched for application is from a diffferent provider" do
        let(:source_application) do
          create(:legal_aid_application,
                 application_ref: "L-TVH-U0T",
                 provider: create(:provider))
        end

        it { is_expected.to be_falsey }

        it "does not assigns the copiable_case attribute to the source application" do
          expect { call_save }.not_to change(instance, :copiable_case)
            .from(nil)
        end

        it "does not store the copy_case_id" do
          expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
        end

        it "adds the appropriate error message" do
          call_save
          expect(instance.errors.messages.values.flatten).to include("The application reference entered cannot be found")
        end
      end
    end

    context "with a valid format but non-existant application reference" do
      let(:search_ref) { "L-FFF-FFF" }

      it { is_expected.to be_falsey }

      it "adds the appropriate error message" do
        call_save
        expect(instance.errors.messages.values.flatten).to include("The application reference entered cannot be found")
      end

      it "does not store the copy_case_id" do
        expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
      end
    end

    context "with no application reference" do
      let(:search_ref) { "" }

      it { is_expected.to be_falsey }

      it "adds the appropriate error message" do
        call_save
        expect(instance.errors.messages.values.flatten).to include("Enter an application reference to search for")
      end

      it "does not store the copy_case_id" do
        expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with a valid application reference" do
      let(:search_ref) { "L-TVH-U0T" }

      it { is_expected.to be_truthy }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not store the copy_case_id" do
        expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
      end
    end

    context "with invalid application reference" do
      let(:search_ref) { "INVALID-REF" }

      it { is_expected.to be_truthy }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not store the copy_case_id" do
        expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
      end
    end

    context "with no application reference entered" do
      let(:search_ref) { "" }

      it { is_expected.to be_nil }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not store the copy_case_id" do
        expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
      end
    end
  end
end
