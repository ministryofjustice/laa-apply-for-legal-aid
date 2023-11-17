require "rails_helper"

RSpec.describe CopyCase::InvitationForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:legal_aid_application) { create(:legal_aid_application) }

  let(:source_application) do
    create(:legal_aid_application,
           application_ref: "L-TVH-U0T",
           provider: legal_aid_application.provider)
  end

  let(:params) do
    {
      model: legal_aid_application,
      copy_case:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with yes chosen" do
      let(:copy_case) { "true" }

      it "updates copy_case" do
        expect { call_save }.to change { legal_aid_application.reload.copy_case }
          .from(nil)
          .to(true)
      end

      it "maintains copy_case_id as nil" do
        expect { call_save }.not_to change { legal_aid_application.reload.copy_case_id }.from(nil)
      end

      context "when no previously chosen" do
        before { legal_aid_application.update!(copy_case: false) }

        it "updates copy_case to true" do
          expect { call_save }.to change(legal_aid_application, :copy_case).from(false).to(true)
        end
      end

      context "when copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case_id: source_application.id)
        end

        it "nullifies copy_case_id" do
          expect { call_save }.to change { legal_aid_application.reload.copy_case_id }.from(source_application.id).to(nil)
        end
      end
    end

    context "with no chosen" do
      let(:copy_case) { "false" }

      it "updates copy_case" do
        expect { call_save }.to change { legal_aid_application.reload.copy_case }
          .from(nil)
          .to(false)
      end

      context "when yes previously chosen" do
        before { legal_aid_application.update!(copy_case: true) }

        it "updates copy_case to false" do
          expect { call_save }.to change(legal_aid_application, :copy_case).from(true).to(false)
        end
      end

      context "when copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case_id: source_application.id)
        end

        it "nullifies copy_case_id" do
          expect { call_save }.to change { legal_aid_application.reload.copy_case_id }.from(source_application.id).to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:copy_case) { "" }

      it "is invalid" do
        call_save
        expect(instance).to be_invalid
      end

      it "adds custom blank error message" do
        call_save
        error_messages = instance.errors.messages.values.flatten
        expect(error_messages).to include("Select yes if you want to copy an application")
      end

      context "when copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case_id: source_application.id)
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
      let(:copy_case) { "true" }

      it "updates copy_case" do
        expect { save_as_draft }.to change(legal_aid_application, :copy_case)
          .from(nil)
          .to(true)
      end

      context "when copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case_id: source_application.id)
        end

        it "nullifies copy_case_id" do
          expect { save_as_draft }.to change { legal_aid_application.reload.copy_case_id }.from(source_application.id).to(nil)
        end
      end
    end

    context "with no chosen" do
      let(:copy_case) { "false" }

      it "updates copy_case" do
        expect { save_as_draft }.to change(legal_aid_application, :copy_case)
          .from(nil)
          .to(false)
      end

      context "when copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case_id: source_application.id)
        end

        it "nullifies copy_case_id" do
          expect { save_as_draft }.to change { legal_aid_application.reload.copy_case_id }.from(source_application.id).to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:copy_case) { "" }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not update copy_case" do
        expect { save_as_draft }.not_to change(legal_aid_application, :copy_case).from(nil)
      end

      context "when copy_case_id already set" do
        before do
          legal_aid_application.update!(copy_case_id: source_application.id)
        end

        it "does not update copy_case_id" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.copy_case_id }.from(source_application.id)
        end
      end
    end
  end
end
