require "rails_helper"

RSpec.describe Incidents::WhenContactWasMadeForm, type: :form do
  subject(:described_form) { described_class.new(params.merge(model: incident)) }

  let(:incident) { create(:incident) }
  let(:first_contact_date) { 5.days.ago.to_date }
  let(:i18n_scope) { "activemodel.errors.models.application_merits_task/incident.attributes" }
  let(:error_locale) { :defined_in_spec }
  let(:message) { I18n.t(error_locale, scope: i18n_scope) }

  let(:params) { { first_contact_date: } }

  describe "#save" do
    before do
      described_form.save!
      incident.reload
    end

    it "updates the incident" do
      expect(incident.first_contact_date).to eq(first_contact_date)
    end

    context "when occurred on is invalid" do
      let(:params) do
        {
          first_contact_date_1i: first_contact_date.year.to_s,
          first_contact_date_2i: "55",
          first_contact_date_3i: first_contact_date.day.to_s,
        }
      end
      let(:error_locale) { "first_contact_date.date_not_valid" }

      it "is invalid" do
        expect(described_form).not_to be_valid
      end

      it "generates an error" do
        expect(described_form.errors[:first_contact_date].join).to match(message)
      end
    end

    context "when first contact date is in the future" do
      let(:first_contact_date) { 1.day.from_now.to_date }
      let(:error_locale) { "first_contact_date.date_is_in_the_future" }

      it "is invalid" do
        expect(described_form).not_to be_valid
      end

      it "generates an error" do
        expect(described_form.errors[:first_contact_date].join).to match(message)
      end
    end

    context "when first contact date is entered in parts" do
      let(:params) do
        {
          first_contact_date_1i: first_contact_date.year.to_s,
          first_contact_date_2i: first_contact_date.month.to_s,
          first_contact_date_3i: first_contact_date.day.to_s,
        }
      end

      it "updates the incident" do
        expect(incident.first_contact_date).to eq(first_contact_date)
      end
    end

    context "with no date entered" do
      let(:first_contact_date) { "" }
      let(:incident) { create(:incident, first_contact_date: nil) }
      let(:error_locale) { "first_contact_date.blank" }

      it "is invalid" do
        expect(described_form).not_to be_valid
      end

      it "generates an error" do
        expect(described_form.errors[:first_contact_date].join).to match(message)
      end
    end

    context "with an invalid partial occurred on date" do
      let(:error_locale) { "first_contact_date.date_not_valid" }
      let(:params) do
        {
          first_contact_date_1i: first_contact_date.year.to_s,
          first_contact_date_2i: "",
          first_contact_date_3i: first_contact_date.day.to_s,
        }
      end

      it "is invalid" do
        expect(described_form).not_to be_valid
      end

      it "generates an error" do
        expect(described_form.errors[:first_contact_date].join).to match(message)
      end
    end
  end
end
