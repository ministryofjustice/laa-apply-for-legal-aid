require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe NatureOfUrgencyForm do
      subject(:form) { described_class.new(params) }

      let(:urgency) { create(:urgency) }
      let(:params) do
        {
          nature_of_urgency:,
          hearing_date_set:,
          hearing_date:,
          model: urgency,
        }
      end

      let(:a_date) { Time.zone.tomorrow }
      let(:nature_of_urgency) { "Hearing is tomorrow" }
      let(:hearing_date_set) { "true" }
      let(:hearing_date) { a_date.to_s(:date_picker) }

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(form).to be_valid
          end
        end

        context "when hearing_date_set is missing" do
          let(:hearing_date_set) { nil }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:hearing_date_set]).to include("Select yes if the hearing date has been set")
          end
        end

        context "when nature_of_urgency is blank" do
          let(:nature_of_urgency) { "" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:nature_of_urgency]).to include("Enter the nature of the urgency")
          end
        end
      end

      context "when hearing_date_set is false" do
        let(:hearing_date_set) { "false" }

        context "and hearing_date is not supplied" do
          let(:hearing_date) { nil }

          it { expect(form).to be_valid }
        end

        # Should it be invalid?/too much
        context "and hearing_date is supplied" do
          let(:hearing_date) { a_date.to_s(:date_picker) }

          it { expect(form).to be_valid }
        end
      end

      context "when hearing_date_set is true" do
        context "and hearing_date supplied" do
          let(:hearing_date) { a_date.to_s(:date_picker) }

          it { expect(form).to be_valid }
        end

        context "and hearing_date is blank" do
          let(:hearing_date) { "" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:hearing_date]).to include("Enter a valid hearing date in the correct format")
          end
        end

        context "and hearing_date is using a 2 digit year" do
          let(:hearing_date) { "#{a_date.day}/#{a_date.month}/#{a_date.strftime('%y').to_i}" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:hearing_date]).to include("Enter a valid hearing date in the correct format")
          end
        end

        context "and hearing_date is using an invalid month" do
          let(:hearing_date) { "#{a_date.day}/13/#{a_date.year}" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:hearing_date]).to include("Enter a valid hearing date in the correct format")
          end
        end

        context "and hearing_date is using an invalid day" do
          let(:hearing_date) { "32/#{a_date.month}/#{a_date.year}" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:hearing_date]).to include("Enter a valid hearing date in the correct format")
          end
        end
      end

      describe "#save_as_draft" do
        subject(:save_as_draft) { form.save_as_draft }

        before { save_as_draft }

        context "when nature_of_urgency is blank" do
          let(:nature_of_urgency) { "" }

          it "is valid" do
            expect(form).to be_valid
          end

          it "updates the urgency record" do
            expect(urgency.reload.nature_of_urgency).to be_nil
            expect(urgency.hearing_date_set).to be true
          end
        end
      end
    end
  end
end
