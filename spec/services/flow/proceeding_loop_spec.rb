require "rails_helper"

RSpec.describe Flow::ProceedingLoop do
  subject(:proceeding_loop) { described_class }

  describe ".next_step" do
    subject(:next_step) { described_class.next_step(legal_aid_application) }

    before do
      allow(Setting).to receive(:enable_mini_loop?).and_return(mini_loop_on?)
      allow(Setting).to receive(:enable_loop?).and_return(loop_on?)
    end

    let(:loop_on?) { false }

    context "when the mini-loop feature flag is off" do
      let(:mini_loop_on?) { false }
      let(:legal_aid_application) { create :legal_aid_application }

      it { is_expected.to be :used_multiple_delegated_functions }
    end

    context "when the mini-loop feature flag is on" do
      let(:mini_loop_on?) { true }
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_proceedings,
               :with_delegated_functions_on_proceedings,
               explicit_proceedings: %i[da001 se013 da005],
               set_lead_proceeding: :da001,
               df_options:,
               provider_step:)
      end
      let(:df_options) { { DA001: [nil, nil], SE013: [nil, nil], DA005: [nil, nil] } }

      context "when the user enters the loop for the first time" do
        let(:provider_step) { "has_other_proceedings" }

        before { allow(legal_aid_application).to receive(:provider_step_params).and_return({}) }

        it { is_expected.to be :client_involvement_type }
      end

      context "when the user is on the second of three proceedings" do
        context "and is on the client involvement page" do
          let(:provider_step) { "client_involvement_type" }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.second.id }) }

          it { is_expected.to be :delegated_functions }
        end

        context "and is on the delegated_function page" do
          let(:provider_step) { "delegated_functions" }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.second.id }) }

          context "when the loop feature flag is off" do
            it { is_expected.to be :client_involvement_type }
          end

          context "when the loop feature flag is on" do
            let(:loop_on?) { true }

            context "and the proceeding has used delegated functions" do
              let(:df_options) { { DA001: [10.days.ago, 10.days.ago], SE013: [10.days.ago, 10.days.ago], DA005: [nil, nil] } }

              it { is_expected.to be :emergency_defaults }
            end

            context "and the proceeding has not used delegated functions" do
              it { is_expected.to be :substantive_defaults }
            end
          end

          context "and the delegated_function date is over a month old" do
            before do
              legal_aid_application.proceedings.in_order_of_addition.second.update!(used_delegated_functions_on: 35.days.ago)
            end

            it { is_expected.to be :confirm_delegated_functions_date }
          end
        end

        context "and is on the emergency_defaults page" do
          let(:loop_on?) { true }
          let(:provider_step) { "emergency_defaults" }
          let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.second }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => proceeding.id }) }

          context "and the user accepts the defaults" do
            before { proceeding.update!(accepted_emergency_defaults: true) }

            it { is_expected.to be :substantive_defaults }
          end

          context "and the user does not accept the defaults" do
            before { proceeding.update!(accepted_emergency_defaults: false) }

            it { is_expected.to be :emergency_level_of_service }
          end
        end

        context "and is on the substantive_defaults page" do
          let(:loop_on?) { true }
          let(:provider_step) { "substantive_defaults" }
          let(:proceeding) { legal_aid_application.proceedings.in_order_of_addition.second }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => proceeding.id }) }

          context "and the user accepts the defaults" do
            before { proceeding.update!(accepted_substantive_defaults: true) }

            it { is_expected.to be :client_involvement_type }
          end

          context "and the user does not accept the defaults" do
            before { proceeding.update!(accepted_emergency_defaults: false) }

            it { is_expected.to be :substantive_level_of_service }
          end
        end

        context "and is on the emergency_level_of_service page" do
          let(:loop_on?) { true }
          let(:provider_step) { "emergency_level_of_service" }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.second.id }) }

          it { is_expected.to be :emergency_scope_limitations }
        end

        context "and is on the substantive_level_of_service page" do
          let(:loop_on?) { true }
          let(:provider_step) { "substantive_level_of_service" }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.second.id }) }

          it { is_expected.to be :substantive_scope_limitations }
        end

        context "and is on the emergency_scope_limitations page" do
          let(:loop_on?) { true }
          let(:provider_step) { "emergency_scope_limitations" }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.second.id }) }

          it { is_expected.to be :substantive_defaults }
        end

        context "and is on the substantive_scope_limitations page" do
          let(:loop_on?) { true }
          let(:provider_step) { "substantive_scope_limitations" }

          before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.second.id }) }

          it { is_expected.to be :client_involvement_type }
        end
      end

      context "when the user is on the final of the three proceedings" do
        let(:provider_step) { "delegated_functions" }

        before do
          allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => legal_aid_application.proceedings.in_order_of_addition.last.id })
        end

        context "when the loop feature flag is off" do
          let(:loop_on?) { false }

          it { is_expected.to be :limitations }
        end

        context "when the loop feature flag is on" do
          let(:loop_on?) { true }

          it { is_expected.to be :substantive_defaults }
        end
      end
    end
  end

  describe ".next_proceeding" do
    # this is only called as part of the mini-loop so no branching/feature-flag checks are needed
    subject(:next_proceeding) { described_class.next_proceeding(legal_aid_application) }

    let(:legal_aid_application) do
      create(:legal_aid_application,
             :with_proceedings,
             explicit_proceedings: %i[da001 se013 da005],
             set_lead_proceeding: :da001,
             provider_step:)
    end
    let(:first_proceeding) { legal_aid_application.proceedings.in_order_of_addition.first }
    let(:second_proceeding) { legal_aid_application.proceedings.in_order_of_addition.second }
    let(:third_proceeding) { legal_aid_application.proceedings.in_order_of_addition.third }

    context "when the user is entering the loop for the first time" do
      let(:provider_step) { "has_other_proceedings" }

      it { is_expected.to eq first_proceeding }
    end

    context "when the user has answered the DF question for the first of three proceedings" do
      let(:provider_step) { "delegated_functions" }

      before { first_proceeding.update!(used_delegated_functions: false) }

      it { is_expected.to eq second_proceeding }
    end

    context "when the user has answered the DF question for all three proceedings" do
      let(:provider_step) { "delegated_functions" }

      before do
        first_proceeding.update!(used_delegated_functions: false)
        second_proceeding.update!(used_delegated_functions: false)
        third_proceeding.update!(used_delegated_functions: false)
      end

      it { is_expected.to eq first_proceeding }
    end

    context "when the user is on the final page of the second proceeding" do
      let(:provider_step) { "delegated_functions" }

      before do
        allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => second_proceeding.id })
        first_proceeding.update!(used_delegated_functions: false)
        second_proceeding.update!(used_delegated_functions: false)
        third_proceeding.update!(used_delegated_functions: false)
      end

      it { is_expected.to eq third_proceeding }
    end

    context "when the user has added an extra proceeding from the check your answers page" do
      let(:provider_step) { "has_other_proceedings" }
      let!(:new_proceeding) { create(:proceeding, :se014, legal_aid_application:) }

      before do
        first_proceeding.update!(used_delegated_functions: false)
        second_proceeding.update!(used_delegated_functions: false)
        third_proceeding.update!(used_delegated_functions: false)
      end

      it { is_expected.to eq new_proceeding }
    end
  end
end
