require "rails_helper"

RSpec.describe LinkCase::ConfirmationForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:params) do
    {
      model: linked_application,
      link_type_code:,
    }
  end

  let(:legal_aid_application) { create(:legal_aid_application, link_case:) }
  let(:link_case) { true }

  let(:linked_application) do
    create(:linked_application,
           lead_application_id: source_application.id, associated_application_id: legal_aid_application.id)
  end

  let(:source_application) do
    create(:legal_aid_application, application_ref: "L-TVH-U0T", provider: legal_aid_application.provider)
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with family link chosen" do
      let(:link_type_code) { "FC_LEAD" }

      it "updates the link_type_code" do
        expect { call_save }.to change(linked_application, :link_type_code).from(nil).to("FC_LEAD")
      end

      context "when case has been copied" do
        let(:link_case) { nil }

        it "updates link_case to true" do
          expect { call_save }.to change { legal_aid_application.reload.link_case }.from(nil).to(true)
        end
      end

      context "when case has not been copied" do
        it "does not change link_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.link_case }.from(true)
        end
      end
    end

    context "with legal link chosen" do
      let(:link_type_code) { "LEGAL" }

      it "updates the link_type_code" do
        expect { call_save }.to change(linked_application, :link_type_code).from(nil).to("LEGAL")
      end

      context "when case has been copied" do
        let(:link_case) { nil }

        it "updates link_case to true" do
          expect { call_save }.to change { legal_aid_application.reload.link_case }.from(nil).to(true)
        end
      end

      context "when case has not been copied" do
        it "does not change link_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.link_case }.from(true)
        end
      end
    end

    context "with no chosen" do
      let(:link_type_code) { "false" }

      it "does not update the link_type_code" do
        expect { call_save }.not_to change(linked_application, :link_type_code).from(nil)
      end

      it "destroys the linked_application" do
        linked_application
        expect { call_save }.to change(LinkedApplication, :count).by(-1)
      end

      context "when case has been copied" do
        let(:link_case) { nil }

        it "does not change link_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.link_case }.from(nil)
        end
      end

      context "when case has not been copied" do
        it "updates link_case to nil" do
          expect { call_save }.to change { legal_aid_application.reload.link_case }.from(true).to(nil)
        end
      end
    end

    context "with no answer chosen" do
      let(:link_type_code) { "" }

      it "is invalid" do
        call_save
        expect(instance).to be_invalid
      end

      it "adds custom blank error message" do
        call_save
        expect(instance.errors.messages.values.flatten).to include("Select an option")
      end

      context "when case has been copied" do
        let(:link_case) { nil }

        it "does not change link_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.link_case }.from(nil)
        end
      end

      context "when case has not been copied" do
        it "does not change link_case" do
          expect { call_save }.not_to change { legal_aid_application.reload.link_case }.from(true)
        end
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with family link chosen" do
      let(:link_type_code) { "FC_LEAD" }

      it { is_expected.to be_nil }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not update linked application" do
        expect { save_as_draft }.not_to change(linked_application, :link_type_code).from(nil)
      end
    end

    context "with legal link chosen" do
      let(:link_type_code) { "LEGAL" }

      it { is_expected.to be_nil }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not update linked application" do
        expect { save_as_draft }.not_to change(linked_application, :link_type_code).from(nil)
      end
    end

    context "with no chosen" do
      let(:link_type_code) { "false" }

      it { is_expected.to be_nil }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not update linked application" do
        expect { save_as_draft }.not_to change(linked_application, :link_type_code).from(nil)
      end
    end

    context "with no answer chosen" do
      let(:link_type_code) { "" }

      it "is valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not update linked application" do
        expect { save_as_draft }.not_to change(linked_application, :link_type_code).from(nil)
      end
    end
  end
end
