require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe DomesticAbuseSummaryForm, type: :form do
      subject(:das_form) { described_class.new(form_params) }

      let(:params) do
        {
          "warning_letter_sent" => "false",
          "warning_letter_sent_details" => "New warning letter sent details",
          "police_notified" => "true",
          "police_notified_details_true" => "New reasons police not notified details",
          "bail_conditions_set" => "true",
          "bail_conditions_set_details" => "New bail conditions set details",
        }
      end
      let(:domestic_abuse_summary) { create(:domestic_abuse_summary) }
      let(:form_params) { params.merge(model: domestic_abuse_summary) }

      describe "extrapolate_police_notified_details" do
        context "when loaded via params" do
          subject(:populated_form) { described_class.new(params) }

          let(:params) do
            {
              warning_letter_sent: "false",
              warning_letter_sent_details: "warning letter sent details",
              police_notified:,
              police_notified_details:,
              bail_conditions_set: "true",
              bail_conditions_set_details: "bail condition set details",
            }
          end

          context "with police_notified false" do
            let(:police_notified) { "false" }
            let(:police_notified_details) { "reasons police not told" }

            it "extrapolates the police_notified_details for display on the page" do
              expect(populated_form).to have_attributes(
                police_notified: "false",
                police_notified_details_false: "reasons police not told",
                police_notified_details_true: be_nil,
              )
            end
          end

          context "with police_notified true" do
            let(:police_notified) { "true" }
            let(:police_notified_details) { "reasons police told" }

            it "extrapolates the police_notified_details for display on the page" do
              expect(populated_form).to have_attributes(
                police_notified: "true",
                police_notified_details_false: nil,
                police_notified_details_true: "reasons police told",
              )
            end
          end
        end
      end

      describe "validation" do
        subject(:valid_form) { das_form.valid? }

        it "when the params are complete" do
          expect(valid_form).to be true
        end

        context "when the parameters are incomplete" do
          let(:params) do
            {
              "warning_letter_sent" => "false",
              "warning_letter_sent_details" => "",
              "police_notified" => "true",
              "police_notified_details_true" => "New reasons police not notified details",
              "bail_conditions_set" => "true",
              "bail_conditions_set_details" => "New bail conditions set details",
            }
          end

          it { expect(valid_form).to be false }
        end

        context "when radio buttons are empty" do
          let(:params) do
            {
              warning_letter_sent: "",
              police_notified: "",
              bail_conditions_set: "",
            }
          end

          it "is invalid with appropriate errors" do
            expect(valid_form).to be false
            expect(das_form.errors[:warning_letter_sent].join).to eq("Select yes if a warning letter has been sent to the opponent")
            expect(das_form.errors[:police_notified].join).to eq("Select yes if the police have been notified")
            expect(das_form.errors[:bail_conditions_set].join).to eq("Select yes if bail conditions have been set")
          end

          it "generates errors in the right order" do
            valid_form
            expect(das_form.errors.attribute_names).to eq(
              %i[
                warning_letter_sent
                police_notified
                bail_conditions_set
              ],
            )
          end
        end

        context "when details are empty even though they should be present" do
          let(:params) do
            {
              warning_letter_sent: "false",
              police_notified: "true",
              bail_conditions_set: "true",
              warning_letter_sent_details: "",
              police_notified_details_true: "",
              bail_conditions_set_details: "",
            }
          end

          it "is invalid with appropriate errors" do
            expect(valid_form).to be false
            expect(das_form.errors[:warning_letter_sent_details].join).to eq("Tell us why a warning letter has not been sent")
            expect(das_form.errors[:police_notified_details_true].join).to eq("Tell us what action the police have taken")
            expect(das_form.errors[:bail_conditions_set_details].join).to eq("Give details of the bail conditions")
          end

          it "generates errors in the right order" do
            valid_form
            expect(das_form.errors.attribute_names).to eq(
              %i[
                warning_letter_sent_details
                police_notified_details_true
                bail_conditions_set_details
              ],
            )
          end
        end
      end

      describe "#save" do
        subject(:save_form) { das_form.save }

        it "updates the opponent with our chosen params" do
          save_form
          expect(das_form).to have_attributes(
            warning_letter_sent: "false",
            warning_letter_sent_details: "New warning letter sent details",
            police_notified: "true",
            police_notified_details_true: "New reasons police not notified details",
            bail_conditions_set: "true",
            bail_conditions_set_details: "New bail conditions set details",
          )
        end
      end
    end
  end
end
