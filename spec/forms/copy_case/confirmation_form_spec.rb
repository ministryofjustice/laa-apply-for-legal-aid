require "rails_helper"

RSpec.describe CopyCase::ConfirmationForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:params) do
    {
      model: legal_aid_application,
      copy_case_id:,
      copy_case_confirmation:,
    }
  end

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:copy_case_id) { source_application.id }

  let(:source_application) do
    create(:legal_aid_application,
           application_ref: "L-TVH-U0T",
           provider: legal_aid_application.provider)
  end

  let(:cloner_klass) { CopyCase::ClonerService }
  let(:cloner) { instance_double(cloner_klass) }

  before do
    allow(CopyCase::ClonerService).to receive(:new).and_return(cloner)
    allow(cloner).to receive(:call)
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with yes chosen" do
      let(:copy_case_confirmation) { "true" }

      it "does not change copy_case" do
        expect { call_save }.not_to change { legal_aid_application.reload.copy_case }
      end

      it "does not change copy_case_id" do
        expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }
      end

      it "calls the cloner service" do
        call_save
        expect(cloner_klass).to have_received(:new).with(legal_aid_application, source_application)
        expect(cloner).to have_received(:call)
      end

      context "when copy_case and copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case: true, copy_case_id: source_application.id)
        end

        it "does not update copy_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.copy_case }.from(true)
        end

        it "does not update copy_case_id" do
          expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }.from(source_application.id)
        end
      end
    end

    context "with no chosen" do
      let(:copy_case_confirmation) { "false" }

      it "does not call the cloner service" do
        call_save
        expect(cloner).not_to have_received(:call)
      end

      context "when copy_case and copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case: true, copy_case_id: source_application.id)
        end

        it "nullifies copy_case" do
          expect { call_save }.to change { legal_aid_application.reload.copy_case }.from(true).to(nil)
        end

        it "nullifies copy_case_id" do
          expect { call_save }.to change { legal_aid_application.reload.copy_case_id }.from(source_application.id).to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:copy_case_confirmation) { "" }

      it "is invalid" do
        call_save
        expect(instance).not_to be_valid
      end

      it "adds custom blank error message" do
        call_save
        expect(instance.errors.messages.values.flatten)
          .to include("Select yes if you want to copy the application")
      end

      context "when copy_case and copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case: true, copy_case_id: source_application.id)
        end

        it "does not update copy_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.copy_case }.from(true)
        end

        it "does not update copy_case_id" do
          expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }.from(source_application.id)
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with yes chosen" do
      let(:copy_case_confirmation) { "true" }

      it "does not call the cloner service" do
        save_as_draft
        expect(cloner).not_to have_received(:call)
      end

      context "when copy_case and copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case: true, copy_case_id: source_application.id)
        end

        it "does not update copy_case" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case }.from(true)
        end

        it "does not update copy_case_id" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(source_application.id)
        end
      end
    end

    context "with no chosen" do
      let(:copy_case_confirmation) { "false" }

      it "does not call the cloner service" do
        save_as_draft
        expect(cloner).not_to have_received(:call)
      end

      context "when copy_case and copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case: true, copy_case_id: source_application.id)
        end

        it "does not update copy_case" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case }.from(true)
        end

        it "does not update copy_case_id" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(source_application.id)
        end
      end
    end

    context "with no answer chosen" do
      let(:copy_case_confirmation) { "" }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      context "when copy_case and copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case: true, copy_case_id: source_application.id)
        end

        it "does not update copy_case" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case }.from(true)
        end

        it "does not update copy_case_id" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(source_application.id)
        end
      end
    end
  end
end
