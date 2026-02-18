require "rails_helper"

RSpec.describe Proceedings::DelegatedFunctionsForm, type: :form do
  subject(:form) { described_class.new(form_params) }

  let(:proceeding) { create(:proceeding, :da001) }
  let(:form_params) { params.merge(model: proceeding) }

  let(:params) do
    {
      used_delegated_functions: used_df?,
      used_delegated_functions_on: df_date,
    }
  end

  describe "#save" do
    subject(:save_form) { form.save }

    context "when the parameters are valid" do
      let(:used_df?) { true }
      let(:df_date) { Time.zone.yesterday.to_s(:date_picker) }

      it "updates the proceeding" do
        expect { save_form }
          .to change { proceeding.reload.attributes.symbolize_keys }
            .from(
              hash_including(
                {
                  used_delegated_functions: nil,
                  used_delegated_functions_on: nil,
                  used_delegated_functions_reported_on: nil,
                },
              ),
            ).to(
              hash_including(
                {
                  used_delegated_functions: true,
                  used_delegated_functions_on: Time.zone.yesterday,
                  used_delegated_functions_reported_on: Time.zone.today,
                },
              ),
            )
      end
    end

    context "when the user selects nothing" do
      let(:used_df?) { nil }
      let(:df_date) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:used_delegated_functions]).to include("Select yes if you have used delegated functions for this proceeding")
      end
    end

    context "with invalid params" do
      context "when the date is in the future" do
        let(:used_df?) { true }
        let(:df_date) { Time.zone.tomorrow.to_s(:date_picker) }

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors[:used_delegated_functions_on]).to include("The date you used delegated functions must be in the past")
        end
      end

      context "when the date is partially incomplete" do
        let(:used_df?) { true }

        let(:params) do
          {
            used_delegated_functions: used_df?,
            used_delegated_functions_on: "#{Time.zone.yesterday.day}//#{Time.zone.yesterday.year}",
          }
        end

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors[:used_delegated_functions_on]).to include("Enter the date you used delegated functions in the correct format")
        end
      end

      context "when the date is using 2 digit year" do
        let(:used_df?) { true }

        let(:params) do
          {
            used_delegated_functions: used_df?,
            used_delegated_functions_on: "#{Time.zone.yesterday.day}/#{Time.zone.yesterday.month}/#{Time.zone.yesterday.strftime('%y').to_i}",
          }
        end

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors[:used_delegated_functions_on]).to include("Enter the date you used delegated functions in the correct format")
        end
      end

      context "when the date is using an invalid month" do
        let(:used_df?) { true }

        let(:params) do
          {
            used_delegated_functions: used_df?,
            used_delegated_functions_on: "#{Time.zone.yesterday.day}/13/#{Time.zone.yesterday.year}",
          }
        end

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors[:used_delegated_functions_on]).to include("Enter the date you used delegated functions in the correct format")
        end
      end

      context "when the date is using an invalid day" do
        let(:used_df?) { true }

        let(:params) do
          {
            used_delegated_functions: used_df?,
            used_delegated_functions_on: "32/#{Time.zone.yesterday.month}/#{Time.zone.yesterday.year}",
          }
        end

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors[:used_delegated_functions_on]).to include("Enter the date you used delegated functions in the correct format")
        end
      end

      context "when the date is (1 second) more than a year old" do
        let(:used_df?) { true }
        let(:df_date) { (Time.zone.today - 12.months - 1.second).to_date.to_s(:date_picker) }

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          earliest_date = 12.months.ago.strftime("%-d %B %Y")
          expect(form.errors[:used_delegated_functions_on]).to include("The date you used delegated functions cannot be before #{earliest_date}")
        end
      end

      context "when the date is exactly a year old" do
        let(:used_df?) { true }
        let(:df_date) { (Time.zone.today - 12.months).to_date.to_s(:date_picker) }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "when the date is (1 second) less than a year old" do
        let(:used_df?) { true }
        let(:df_date) { (Time.zone.today - 12.months + 1.second).to_date.to_s(:date_picker) }

        it "is valid" do
          expect(form).to be_valid
        end
      end
    end
  end

  describe "#save as draft" do
    subject(:save_form_draft) { form.save_as_draft }

    let(:used_df?) { true }
    let(:df_date) { Time.zone.yesterday.to_s(:date_picker) }

    it "updates each application proceeding type if they are entered" do
      expect { save_form_draft }
        .to change { proceeding.reload.attributes.symbolize_keys }
          .from(
            hash_including(
              {
                used_delegated_functions: nil,
                used_delegated_functions_on: nil,
                used_delegated_functions_reported_on: nil,
              },
            ),
          ).to(
            hash_including(
              {
                used_delegated_functions: true,
                used_delegated_functions_on: Time.zone.yesterday,
                used_delegated_functions_reported_on: Time.zone.today,
              },
            ),
          )
    end

    context "when nothing selected" do
      let(:params) { {} }

      it "does NOT update the proceeding" do
        expect { save_form_draft }.not_to change(proceeding, :used_delegated_functions).from(nil)
      end

      it "is invalid with expected error" do
        expect(form).not_to be_valid
        expect(form.errors[:used_delegated_functions]).to include("Select yes if you have used delegated functions for this proceeding")
        expect(form.errors[:used_delegated_functions_on]).to be_empty
      end
    end

    context "when the date is invalid" do
      let(:used_df?) { true }
      let(:df_date) { (Time.zone.yesterday - 15.months).to_date.to_s(:date_picker) }

      it "is invalid with expected error" do
        expect(form).not_to be_valid
        earliest_date = 12.months.ago.strftime("%-d %B %Y")
        expect(form.errors[:used_delegated_functions_on]).to include("The date you used delegated functions cannot be before #{earliest_date}")
      end
    end

    context "when the date is in future" do
      let(:used_df?) { true }
      let(:df_date) { Time.zone.tomorrow.to_date.to_s(:date_picker) }

      it "is invalid with expected error" do
        expect(form).not_to be_valid
        expect(form.errors[:used_delegated_functions_on]).to include("The date you used delegated functions must be in the past")
      end
    end
  end
end
