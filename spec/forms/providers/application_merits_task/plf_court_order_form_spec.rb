require "rails_helper"

module Providers::ApplicationMeritsTask
  RSpec.describe PLFCourtOrderForm do
    let(:legal_aid_application) { create :legal_aid_application }
    let(:params) do
      {
        model: legal_aid_application,
        plf_court_order:,
      }
    end

    describe "#validate" do
      subject(:form) { described_class.new(params) }

      context "when plf_court_order is a valid value" do
        let(:plf_court_order) { "true" }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "when plf_court_order is empty" do
        let(:plf_court_order) { "" }

        it "is is not valid" do
          expect(form).not_to be_valid
        end
      end

      context "when plf_court_order is not a valid value" do
        let(:plf_court_order) { "gibberish" }

        it "is invalid" do
          expect(form).not_to be_valid
        end
      end
    end

    describe "#copy_of_court_order?" do
      subject(:form) { described_class.new(params) }

      context "when plf_court_order is 'true'" do
        let(:plf_court_order) { "true" }

        it "returns true" do
          expect(form.copy_of_court_order?).to be true
        end
      end

      context "when plf_court_order is 'false'" do
        let(:plf_court_order) { "false" }

        it "returns false" do
          expect(form.copy_of_court_order?).to be false
        end
      end
    end

    describe "#save" do
      subject(:save_form) { described_class.new(params).save }

      context "when the form is blank" do
        let(:plf_court_order) { nil }

        it "does not update the record" do
          expect { save_form }.not_to change { legal_aid_application.reload.plf_court_order }.from(nil)
        end
      end

      context "when the form is invalid" do
        let(:plf_court_order) { "foobar" }

        it "does not update the record" do
          expect { save_form }.not_to change { legal_aid_application.reload.plf_court_order }.from(nil)
        end
      end

      context "when plf_court_order is valid" do
        let(:plf_court_order) { "true" }

        it "updates the record" do
          expect { save_form }.to change { legal_aid_application.reload.plf_court_order }.from(nil).to(true)
        end
      end
    end

    describe "#save_as_draft" do
      subject(:save_as_draft) { described_class.new(params).save_as_draft }

      context "when the form is blank" do
        let(:plf_court_order) { nil }

        it "does not update the record" do
          expect { save_as_draft }.not_to change { legal_aid_application.reload.plf_court_order }.from(nil)
        end
      end

      context "when plf_court_order is valid" do
        let(:plf_court_order) { "true" }

        it "updates the record" do
          expect { save_as_draft }.to change { legal_aid_application.reload.plf_court_order }.from(nil).to(true)
        end
      end
    end
  end
end
