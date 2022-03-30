require "rails_helper"

module Dashboard
  module WidgetDataProviders
    RSpec.describe Applications do
      describe ".handle" do
        it "returns the unqualified widget name" do
          expect(described_class.handle).to eq "applications"
        end
      end

      describe ".dataset_definition" do
        it "returns hash of field definitions" do
          expected_definition = { fields:
                                    [
                                      { name: "Date", type: "date" },
                                      { name: "Started applications", optional: false, type: "number" },
                                      { name: "Submitted applications", optional: false, type: "number" },
                                      { name: "Submitted passported applications", optional: false, type: "number" },
                                      { name: "Submitted nonpassported applications", optional: false, type: "number" },
                                      { name: "Total submitted applications", optional: false, type: "number" },
                                      { name: "Failed applications", optional: false, type: "number" },
                                      { name: "Delegated function applications", optional: false, type: "number" },
                                    ],
                                  unique_by: ["date"] }.to_json
          expect(described_class.dataset_definition.to_json).to eq expected_definition
        end
      end

      describe ".data" do
        before { create_apps }

        let(:date) { Date.new(2019, 12, 12) }

        it "returns the expected data" do
          travel_to(date) do
            expect(described_class.data).to eq expected_data
          end
        end

        def expected_data
          [
            { "date" => "2019-11-22", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-23", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-24", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-25", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-26", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-27", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-28", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-29", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-11-30", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-01", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-02", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-03", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-04", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-05", "started_apps" => 0, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-06", "started_apps" => 3, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-07", "started_apps" => 2, "submitted_apps" => 0, "total_submitted_apps" => 0, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 1, "delegated_func_apps" => 0 },
            { "date" => "2019-12-08", "started_apps" => 2, "submitted_apps" => 1, "total_submitted_apps" => 1, "submitted_passported_apps" => 1, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 2 },
            { "date" => "2019-12-09", "started_apps" => 1, "submitted_apps" => 0, "total_submitted_apps" => 1, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-10", "started_apps" => 5, "submitted_apps" => 0, "total_submitted_apps" => 1, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 0 },
            { "date" => "2019-12-11", "started_apps" => 8, "submitted_apps" => 3, "total_submitted_apps" => 4, "submitted_passported_apps" => 2, "submitted_nonpassported_apps" => 1, "failed_apps" => 0, "delegated_func_apps" => 4 },
            { "date" => "2019-12-12", "started_apps" => 5, "submitted_apps" => 0, "total_submitted_apps" => 4, "submitted_passported_apps" => 0, "submitted_nonpassported_apps" => 0, "failed_apps" => 0, "delegated_func_apps" => 4 },
          ]
        end

        def create_apps
          create_2019_12_06
          create_2019_12_07
          create_2019_12_08
          create_2019_12_09
          create_2019_12_10
          create_2019_12_11
          create_2019_12_12
        end

        def create_2019_12_06
          travel_to(Date.new(2019, 12, 6)) do
            create_new(3)
          end
        end

        def create_2019_12_07
          travel_to(Date.new(2019, 12, 7)) do
            create_new(1)
            create_ccms_submisson_failure(1)
          end
        end

        def create_2019_12_08
          travel_to(Date.new(2019, 12, 8)) do
            create_df(1)
            create_passported(1)
          end
        end

        def create_2019_12_09
          travel_to(Date.new(2019, 12, 9)) do
            create_new(1)
          end
        end

        def create_2019_12_10
          travel_to(Date.new(2019, 12, 10)) do
            create_new(5)
          end
        end

        def create_2019_12_11
          travel_to(Date.new(2019, 12, 11)) do
            create_new(3)
            create_df(2)
            create_non_passported(1)
            create_passported(2)
          end
        end

        def create_2019_12_12
          travel_to(Date.new(2019, 12, 12)) do
            create_new(1)
            create_incomplete_passported(2)
            create_incomplete_non_passported(2)
          end
        end

        def create_new(num)
          FactoryBot.create_list :legal_aid_application, num
        end

        def create_ccms_submisson_failure(num)
          FactoryBot.create_list :ccms_submission, num, aasm_state: "failed"
        end

        def create_df(num)
          FactoryBot.create_list :legal_aid_application, num, :with_proceedings, :with_delegated_functions_on_proceedings, df_options: { DA001: df_date, DA004: df_date }
        end

        def create_non_passported(num)
          FactoryBot.create_list :legal_aid_application, num, :non_passported, merits_submitted_at: Time.zone.today
        end

        def create_passported(num)
          FactoryBot.create_list :legal_aid_application, num, :passported, :with_proceedings, :with_delegated_functions_on_proceedings, df_options: { DA001: df_date, DA004: df_date }, merits_submitted_at: Time.zone.today
        end

        def create_incomplete_passported(num)
          FactoryBot.create_list :legal_aid_application, num, :passported, :with_proceedings, :with_delegated_functions_on_proceedings, df_options: { DA001: df_date, DA004: df_date }
        end

        def create_incomplete_non_passported(num)
          FactoryBot.create_list :legal_aid_application, num, :non_passported, :with_proceedings, :with_delegated_functions_on_proceedings, df_options: { DA001: df_date, DA004: df_date }
        end

        def df_date
          Time.zone.yesterday.to_date
        end
      end
    end
  end
end
