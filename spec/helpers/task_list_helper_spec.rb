require "rails_helper"

RSpec.describe TaskListHelper do
  describe "#task_list_item" do
    context "when passed an application with section 8 proceeding_types" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }

      context "with involded children task list item" do
        context "when an involved child already added" do
          before { create(:involved_child, legal_aid_application:) }

          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a class="govuk-link" aria_describedby="children_application-status" aria-label="Children involved in this application" href="/providers/applications/#{legal_aid_application.id}/has_other_involved_children?locale=en">Children involved in this application</a>
                </span>
                <strong class="govuk-tag app-task-list__tag" id="children_application__status">Completed</strong>
              </li>
            RESULT
          end

          it "returns expected html" do
            expect(helper.task_list_item(name: :children_application,
                                         status: :complete,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end

        context "when no involved child added" do
          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a class="govuk-link" aria_describedby="children_application-status" aria-label="Children involved in this application" href="/providers/applications/#{legal_aid_application.id}/involved_children/new?locale=en">Children involved in this application</a>
                </span>
                <strong class="govuk-tag govuk-tag--grey app-task-list__tag" id="children_application__status">Not started</strong>
              </li>
            RESULT
          end

          it "returns expected html" do
            expect(helper.task_list_item(name: :children_application,
                                         status: :not_started,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end
      end

      context "with chances of success list item" do
        let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }

        context "when chance of success already added" do
          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a class="govuk-link" aria_describedby="chances_of_success-status" aria-label="Chances of success" href="/providers/merits_task_list/#{proceeding.id}/chances_of_success?locale=en">Chances of success</a>
                </span>
                <strong class="govuk-tag app-task-list__tag" id="chances_of_success_DA001_status">Completed</strong>
              </li>
            RESULT
          end

          it "returns expected html" do
            expect(helper.task_list_item(name: :chances_of_success,
                                         status: :complete,
                                         legal_aid_application:,
                                         ccms_code: :DA001)).to eq expected
          end
        end
      end

      context "with opponent task list item" do
        context "when no opponents added" do
          before { legal_aid_application.opponents.destroy_all }

          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a class="govuk-link" aria_describedby="opponent_name-status" aria-label="Opponents" href="/providers/applications/#{legal_aid_application.id}/opponent_type?locale=en">Opponents</a>
                </span>
                <strong class="govuk-tag govuk-tag--grey app-task-list__tag" id="opponent_name__status">Not started</strong>
              </li>
            RESULT
          end

          it "returns expected html" do
            expect(helper.task_list_item(name: :opponent_name,
                                         status: :not_started,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end

        context "when an opponent already added" do
          before { create(:opponent, :for_individual, legal_aid_application:) }

          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a class="govuk-link" aria_describedby="opponent_name-status" aria-label="Opponents" href="/providers/applications/#{legal_aid_application.id}/has_other_opponent?locale=en">Opponents</a>
                </span>
                <strong class="govuk-tag app-task-list__tag" id="opponent_name__status">Completed</strong>
              </li>
            RESULT
          end

          it "returns expected html" do
            expect(helper.task_list_item(name: :opponent_name,
                                         status: :complete,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end
      end
    end
  end

  describe "#task_list_includes?" do
    subject(:task_list_includes?) { helper.task_list_includes?(legal_aid_application, task_name) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
    let(:task_name) { :opponent_name }

    before do
      create(:legal_framework_merits_task_list, :da001, legal_aid_application:)
    end

    context "when task name is included in list of required tasks from LFA" do
      let(:task_name) { :opponent_name }

      it { is_expected.to be_truthy }
    end

    context "when task name is NOT included in list of required tasks from LFA" do
      let(:task_name) { :why_matter_opposed }

      it { is_expected.to be_falsey }
    end
  end
end
