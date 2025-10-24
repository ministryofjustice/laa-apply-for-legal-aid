require "rails_helper"

module Proceedings
  RSpec.describe FinalHearingForm do
    subject(:form) { described_class.new(params) }

    let(:params) do
      {
        work_type:,
        listed:,
        date:,
        details:,
        proceeding_id:,
      }
    end

    let(:work_type) { :substantive }
    let(:listed) { "false" }
    let(:date) { nil }
    let(:details) { "Reasons for not being listed" }
    let(:proceeding) { create(:proceeding, :da001) }
    let(:proceeding_id) { proceeding.id }

    describe "#valid?" do
      context "when all fields are valid" do
        it "returns true" do
          expect(form).to be_valid
        end
      end

      context "when work_type is set to an invalid value" do
        let(:work_type) { :wobble }

        it { expect(form).not_to be_valid }
      end

      context "when listed is missing" do
        let(:listed) { nil }

        it { expect(form).not_to be_valid }

        it "is invalid with expected error" do
          expect(form).to be_invalid
          expect(form.errors.messages[:listed]).to include("Select yes if the proceeding has been listed for a final hearing")
        end
      end

      context "when listed is true" do
        let(:listed) { "true" }

        context "and the date is provided" do
          let(:date) { Time.zone.tomorrow.to_s(:date_picker) }

          it { expect(form).to be_valid }
        end

        context "and the date is missing" do
          let(:date) { "" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:date]).to include("Enter a valid final hearing date in the correct format")
          end
        end

        context "and the date is using 2 digit year" do
          let(:date) { "#{Time.zone.today.day}/#{Time.zone.today.month}/#{Time.zone.today.strftime('%y').to_i}" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:date]).to include("Enter a valid final hearing date in the correct format")
          end
        end

        context "and the date is using an invalid month" do
          let(:date) { "#{Time.zone.today.day}/13/#{Time.zone.today.year}" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:date]).to include("Enter a valid final hearing date in the correct format")
          end
        end

        context "and the date is using an invalid day" do
          let(:date) { "32/#{Time.zone.today.month}/#{Time.zone.today.year}" }

          it "is invalid with expected error" do
            expect(form).to be_invalid
            expect(form.errors.messages[:date]).to include("Enter a valid final hearing date in the correct format")
          end
        end
      end
    end

    describe "#save" do
      subject(:save_form) { described_class.new(form_params).save }

      let(:form_params) { params }
      let(:final_hearing) { proceeding.final_hearings.substantive.first }

      before { save_form }

      context "when the form is invalid" do
        let(:listed) { nil }

        it "does not create a matter opposition record" do
          expect(final_hearing).to be_nil
        end
      end

      context "when the form is valid" do
        context "and listed is false" do
          it "creates a final hearing record" do
            expect(final_hearing).to have_attributes(
              proceeding_id: proceeding.id,
              listed: false,
              details: "Reasons for not being listed",
              date: nil,
            )
          end
        end

        context "and listed is true" do
          let(:listed) { "true" }
          let(:date) { Time.zone.today.to_s(:date_picker) }
          let(:details) { nil }

          it "creates a final hearing record" do
            expect(final_hearing).to have_attributes(
              proceeding_id: proceeding.id,
              listed: true,
              details: nil,
              date: Time.zone.today,
            )
          end
        end
      end

      context "when a previous object exists and the user changes answers" do
        let(:final_hearing) { create(:final_hearing, proceeding:) }
        let(:form_params) { params.merge(model: final_hearing) }

        describe "and the user changes answers" do
          it "updates the existing record, blanking where necessary" do
            expect(final_hearing).to have_attributes(
              proceeding_id: proceeding.id,
              listed: false,
              details: "Reasons for not being listed",
              date: nil,
            )
          end
        end
      end
    end
  end
end
