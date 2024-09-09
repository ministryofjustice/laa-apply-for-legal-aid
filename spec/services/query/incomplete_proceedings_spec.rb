require "rails_helper"

module Query
  RSpec.describe IncompleteProceedings do
    subject(:query) { described_class.call(proceeding.legal_aid_application) }

    context "when a proceeding has all values present" do
      let(:proceeding) do
        create(:proceeding, :da001, :with_df_date,
               accepted_emergency_defaults: true,
               accepted_substantive_defaults: true)
      end

      it { expect(query).not_to include(proceeding) }
    end

    context "when a proceeding has not used df and accepted_emergency_defaults is missing" do
      let(:proceeding) do
        create(:proceeding, :da001,
               used_delegated_functions: false,
               accepted_emergency_defaults: nil,
               accepted_substantive_defaults: true)
      end

      it { expect(query).not_to include(proceeding) }
    end

    context "when a proceeding has not had the client involvement type question answered" do
      let(:proceeding) do
        create(:proceeding, :da001, :with_df_date,
               client_involvement_type_description: nil,
               client_involvement_type_ccms_code: nil,
               used_delegated_functions: true,
               accepted_emergency_defaults: true,
               accepted_substantive_defaults: true)
      end

      it { expect(query).to include(proceeding) }
    end

    context "when a proceeding has not had the used_delegated_functions question answered" do
      let(:proceeding) do
        create(:proceeding, :da001, :with_df_date,
               used_delegated_functions: nil,
               accepted_emergency_defaults: true,
               accepted_substantive_defaults: true)
      end

      it { expect(query).to include(proceeding) }
    end

    context "when a proceeding has not had the accepted_substantive_defaults question answered" do
      context "and is not a special children act matter type" do
        let(:proceeding) do
          create(:proceeding, :da001, :with_df_date,
                 accepted_substantive_defaults: nil)
        end

        it { expect(query).to include(proceeding) }
      end

      context "and is a special children act matter type" do
        let(:proceeding) do
          create(:proceeding, :pb003, :without_df_date,
                 accepted_substantive_defaults: nil,
                 client_involvement_type_ccms_code: "D",
                 used_delegated_functions: false,
                 accepted_emergency_defaults: nil)
        end

        it { expect(query).not_to include(proceeding) }
      end
    end

    context "when a proceeding has not accepted_substantive_defaults and not set a new default" do
      let(:proceeding) do
        create(:proceeding, :da001, :with_df_date,
               accepted_substantive_defaults: false,
               substantive_level_of_service: nil,
               substantive_level_of_service_name: nil,
               substantive_level_of_service_stage: nil)
      end

      it { expect(query).to include(proceeding) }
    end

    context "when a proceeding has not accepted_emergency_defaults and not set a new default" do
      let(:proceeding) do
        create(:proceeding, :da001, :with_df_date,
               accepted_emergency_defaults: false,
               emergency_level_of_service: nil,
               emergency_level_of_service_name: nil,
               emergency_level_of_service_stage: nil)
      end

      it { expect(query).to include(proceeding) }
    end

    context "when a proceeding has not had the accepted_emergency_defaults question answered" do
      context "and is not a special children act matter type" do
        let(:proceeding) do
          create(:proceeding, :da001, :with_df_date,
                 accepted_emergency_defaults: nil,
                 emergency_level_of_service: nil,
                 emergency_level_of_service_name: nil,
                 emergency_level_of_service_stage: nil)
        end

        it { expect(query).to include(proceeding) }
      end

      context "and is a special children act matter type" do
        let(:proceeding) do
          create(:proceeding, :pb003, :with_df_date,
                 accepted_substantive_defaults: nil,
                 client_involvement_type_ccms_code: "D",
                 used_delegated_functions: false,
                 accepted_emergency_defaults: nil)
        end

        it { expect(query).not_to include(proceeding) }
      end
    end

    context "when a proceeding has rejected the substantive defaults and not added scope_limitations" do
      let!(:proceeding) do
        create(:proceeding, :da001, :with_df_date,
               no_scope_limitations: true,
               accepted_emergency_defaults: true,
               accepted_substantive_defaults: false)
      end

      it { expect(query).to include(proceeding) }
    end
  end
end
