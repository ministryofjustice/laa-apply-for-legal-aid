require "rails_helper"

module Proceedings
  RSpec.describe FinalHearingForm do
    subject(:final_hearing_form) { described_class.new(params) }

    let(:params) do
      {
        work_type:,
        listed:,
        date_1i:,
        date_2i:,
        date_3i:,
        details:,
        proceeding_id:,
      }
    end
    let(:work_type) { :substantive }
    let(:listed) { "false" }
    let(:date_1i) { nil }
    let(:date_2i) { nil }
    let(:date_3i) { nil }
    let(:details) { "Reasons for not being listed" }
    let(:proceeding) { create(:proceeding, :da001) }
    let(:proceeding_id) { proceeding.id }

    describe "#valid?" do
      context "when all fields are valid" do
        it "returns true" do
          expect(final_hearing_form).to be_valid
        end
      end

      context "when work_type is set to an invalid value" do
        let(:work_type) { :wobble }

        it { expect(final_hearing_form).not_to be_valid }
      end

      context "when listed is missing" do
        let(:listed) { nil }

        it { expect(final_hearing_form).not_to be_valid }
      end

      context "when listed is true" do
        let(:listed) { "true" }

        context "and the date is missing" do
          it { expect(final_hearing_form).not_to be_valid }
        end

        context "and the date information is provided" do
          let(:date_1i) { Date.tomorrow.year }
          let(:date_2i) { Date.tomorrow.month }
          let(:date_3i) { Date.tomorrow.day }

          it { expect(final_hearing_form).to be_valid }
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
          let(:date_1i) { Time.zone.today.year }
          let(:date_2i) { Time.zone.today.month }
          let(:date_3i) { Time.zone.today.day }
          let(:details) { nil }

          it "creates a final hearing record" do
            expect(final_hearing).to have_attributes(
              proceeding_id: proceeding.id,
              listed: true,
              details: nil,
              date: Time.zone.today,
            )
          end

          context "and the year is greater than the current year" do
            let(:current_year) { Time.current.strftime("%y").to_i }
            let(:date_1i) { current_year + 1 }

            it "sets the final hearing date to be 20xx" do
              expect(final_hearing).to have_attributes(date: Date.new("20#{current_year + 1}".to_i, Time.zone.today.month, Time.zone.today.day))
            end
          end

          context "and the year is less than the current year" do
            let(:current_year) { Time.current.strftime("%y").to_i }
            let(:date_1i) { current_year - 1 }

            it "sets the final hearing date to be 20xx" do
              expect(final_hearing).to have_attributes(date: Date.new("20#{current_year - 1}".to_i, Time.zone.today.month, Time.zone.today.day))
            end
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
