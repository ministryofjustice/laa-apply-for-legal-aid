require "rails_helper"

RSpec.describe LinkCase::SearchForm, type: :form do
  subject(:instance) { described_class.new(params) }

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:linked_application) { LinkedApplication.new }

  let(:params) do
    {
      model: linked_application,
      legal_aid_application:,
      search_ref:,
    }
  end

  describe "#save" do
    subject(:call_save) { instance.save }

    context "with a valid application reference" do
      let(:search_ref) { "L-TVH-U0T" }

      let(:source_application) do
        create(:legal_aid_application, application_ref: "L-TVH-U0T")
      end

      before { source_application }

      it { is_expected.to be_truthy }

      it "assigns the linkable_case attribute to the source application" do
        expect { call_save }.to change(instance, :linkable_case).from(nil).to(source_application)
      end

      it "creates linked application" do
        expect { call_save }.to change(LinkedApplication, :count).from(0).to(1)
      end
    end

    context "with a mixed case and whitespace including but otherwise valid application reference" do
      let(:search_ref) { " \t l-TVH-u0t  \t" }

      let(:source_application) do
        create(:legal_aid_application, application_ref: "L-TVH-U0T")
      end

      before { source_application }

      it "finds the application id" do
        expect { call_save }.to change(instance, :linkable_case).from(nil).to(source_application)
      end
    end

    context "with a valid format but non-existant application reference" do
      let(:search_ref) { "L-FFF-FFF" }

      it { is_expected.to be_falsey }

      it "adds the appropriate error message" do
        call_save
        expect(instance.errors.messages.values.flatten).to include("The application reference entered cannot be found")
      end

      it "does not create linked application" do
        expect { call_save }.not_to change(LinkedApplication, :count).from(0)
      end
    end

    context "with no application reference" do
      let(:search_ref) { "" }

      it { is_expected.to be_falsey }

      it "adds the appropriate error message" do
        call_save
        expect(instance.errors.messages.values.flatten).to include("Enter an application reference to search for")
      end

      it "does not create linked application" do
        expect { call_save }.not_to change(LinkedApplication, :count).from(0)
      end
    end
  end

  describe "#save_as_draft" do
    subject(:save_as_draft) { instance.save_as_draft }

    context "with a valid application reference" do
      let(:search_ref) { "L-TVH-U0T" }

      it { is_expected.to be_falsey }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not create linked application" do
        expect { save_as_draft }.not_to change(LinkedApplication, :count).from(0)
      end
    end

    context "with invalid application reference" do
      let(:search_ref) { "INVALID-REF" }

      it { is_expected.to be_falsey }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not create linked application" do
        expect { save_as_draft }.not_to change(LinkedApplication, :count).from(0)
      end
    end

    context "with no application reference entered" do
      let(:search_ref) { "" }

      it { is_expected.to be_falsey }

      it "considered valid" do
        save_as_draft
        expect(instance).to be_valid
      end

      it "does not create linked application" do
        expect { save_as_draft }.not_to change(LinkedApplication, :count).from(0)
      end
    end
  end
end
