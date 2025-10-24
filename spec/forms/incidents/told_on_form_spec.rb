require "rails_helper"

RSpec.describe Incidents::ToldOnForm, type: :form do
  subject(:form) { described_class.new(params.merge(model: incident)) }

  let(:incident) { create(:incident) }
  let(:params) { { occurred_on: occurred_on_string, told_on: told_on_string } }

  let(:told_on_string) { 3.days.ago.to_date.to_s(:date_picker) }
  let(:occurred_on_string) { 5.days.ago.to_date.to_s(:date_picker) }

  describe "#valid?" do
    context "when the told_on and occurred on dates are provided" do
      let(:told_on_string) { 3.days.ago.to_date.to_s(:date_picker) }
      let(:occurred_on_string) { 5.days.ago.to_date.to_s(:date_picker) }

      it { expect(form).to be_valid }
    end

    context "when the told_on date is missing" do
      let(:told_on_string) { "" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:told_on]).to include("Enter the date your client told you about the latest incident")
      end
    end

    context "when the told_on date is using 2 digit year" do
      let(:told_on_string) { "#{Time.zone.today.day}/#{Time.zone.today.month}/#{Time.zone.today.strftime('%y').to_i}" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:told_on]).to include("Enter a valid date for when your client contacted you about the incident in the correct format")
      end
    end

    context "when the told_on date is using an invalid month" do
      let(:told_on_string) { "#{Time.zone.today.day}/13/#{Time.zone.today.year}" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:told_on]).to include("Enter a valid date for when your client contacted you about the incident in the correct format")
      end
    end

    context "when the told_on date is using an invalid day" do
      let(:told_on_string) { "32/#{Time.zone.today.month}/#{Time.zone.today.year}" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:told_on]).to include("Enter a valid date for when your client contacted you about the incident in the correct format")
      end
    end

    context "when the told_on date is in the future" do
      let(:told_on_string) { Time.zone.tomorrow.to_s(:date_picker) }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:told_on]).to include("Date your client told you about the latest incident must be in the past")
      end
    end

    context "when the occurred_on date is missing" do
      let(:occurred_on_string) { "" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:occurred_on]).to include("Enter the date the incident occurred")
      end
    end

    context "when the occurred_on date is using 2 digit year" do
      let(:occurred_on_string) { "#{Time.zone.today.day}/#{Time.zone.today.month}/#{Time.zone.today.strftime('%y').to_i}" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:occurred_on]).to include("Enter a valid date for when the incident occurred in the correct format")
      end
    end

    context "when the occurred_on date is using an invalid month" do
      let(:occurred_on_string) { "#{Time.zone.today.day}/13/#{Time.zone.today.year}" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:occurred_on]).to include("Enter a valid date for when the incident occurred in the correct format")
      end
    end

    context "when the occurred_on date is using an invalid day" do
      let(:occurred_on_string) { "32/#{Time.zone.today.month}/#{Time.zone.today.year}" }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:occurred_on]).to include("Enter a valid date for when the incident occurred in the correct format")
      end
    end

    context "when the occurred_on date is in the future" do
      let(:occurred_on_string) { Time.zone.tomorrow.to_s(:date_picker) }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:occurred_on]).to include("Date the incident occurred must be in the past")
      end
    end

    context "when the occurred_on is after the told_on date" do
      let(:told_on_string) { 2.days.ago.to_date.to_s(:date_picker) }
      let(:occurred_on_string) { 1.day.ago.to_date.to_s(:date_picker) }

      it "is invalid with expected error" do
        expect(form).to be_invalid
        expect(form.errors.messages[:occurred_on]).to include("Date the incident occurred must be before the date your client told you about it")
      end
    end
  end

  describe "#save" do
    before do
      form.save!
      incident.reload
    end

    it "updates the incident" do
      expect(incident.told_on).to eq(3.days.ago.to_date)
      expect(incident.occurred_on).to eq(5.days.ago.to_date)
    end
  end
end
