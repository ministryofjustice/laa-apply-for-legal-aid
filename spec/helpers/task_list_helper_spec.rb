require "rails_helper"

RSpec.describe TaskListHelper do
  context "when passed an application with section 8 proceeding_types" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }

    context "with a child already added" do
      before { create(:involved_child, legal_aid_application:) }

      let(:expected) do
        <<~RESULT
          <li class="app-task-list__item">
            <span class="app-task-list__task-name">
                <a aria_describedby="children_application-status" aria-label="Children involved in this application" href="/providers/applications/#{legal_aid_application.id}/has_other_involved_children?locale=en">Children involved in this application</a>
            </span>
            <strong class="govuk-tag app-task-list__tag" id="children_application__status">Completed</strong>
          </li>
        RESULT
      end

      it "returns a link" do
        expect(helper.task_list_item(name: :children_application,
                                     status: :complete,
                                     legal_aid_application:,
                                     ccms_code: nil)).to eq expected
      end
    end

    context "with no child added" do
      let(:expected) do
        <<~RESULT
          <li class="app-task-list__item">
            <span class="app-task-list__task-name">
                <a aria_describedby="children_application-status" aria-label="Children involved in this application" href="/providers/applications/#{legal_aid_application.id}/involved_children/new?locale=en">Children involved in this application</a>
            </span>
            <strong class="govuk-tag govuk-tag--grey app-task-list__tag" id="children_application__status">Not started</strong>
          </li>
        RESULT
      end

      it "returns a link" do
        expect(helper.task_list_item(name: :children_application,
                                     status: :not_started,
                                     legal_aid_application:,
                                     ccms_code: nil)).to eq expected
      end
    end

    context "with chances of success" do
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }

      let(:expected) do
        <<~RESULT
          <li class="app-task-list__item">
            <span class="app-task-list__task-name">
                <a aria_describedby="chances_of_success-status" aria-label="Chances of success" href="/providers/merits_task_list/#{proceeding.id}/chances_of_success?locale=en">Chances of success</a>
            </span>
            <strong class="govuk-tag app-task-list__tag" id="chances_of_success_DA001_status">Completed</strong>
          </li>
        RESULT
      end

      it "returns a link" do
        expect(helper.task_list_item(name: :chances_of_success,
                                     status: :complete,
                                     legal_aid_application:,
                                     ccms_code: :DA001)).to eq expected
      end
    end

    context "with opponent" do
      context "when opponent_organisations flag is set to true" do
        before do
          allow(Setting).to receive(:opponent_organisations?).and_return(true)
        end

        context "with no opponents added" do
          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a aria_describedby="opponent_name-status" aria-label="Opponents" href="/providers/applications/#{legal_aid_application.id}/opponent_type?locale=en">Opponents</a>
                </span>
                <strong class="govuk-tag govuk-tag--grey app-task-list__tag" id="opponent_name__status">Not started</strong>
              </li>
            RESULT
          end
          let(:opponent) { create(:opponent, :for_organisation, legal_aid_application:) }

          it "returns a link" do
            expect(helper.task_list_item(name: :opponent_name,
                                         status: :not_started,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end

        context "with an opponent already added" do
          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a aria_describedby="opponent_name-status" aria-label="Opponents" href="/providers/applications/#{legal_aid_application.id}/has_other_opponent?locale=en">Opponents</a>
                </span>
                <strong class="govuk-tag app-task-list__tag" id="opponent_name__status">Completed</strong>
              </li>
            RESULT
          end

          it "returns a link" do
            create(:opponent, :for_organisation, legal_aid_application:)
            expect(helper.task_list_item(name: :opponent_name,
                                         status: :complete,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end
      end

      context "when opponent_organisations flag is set to false" do
        before do
          allow(Setting).to receive(:opponent_organisations?).and_return(false)
        end

        context "with no opponents added" do
          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a aria_describedby="opponent_name-status" aria-label="Opponents" href="/providers/applications/#{legal_aid_application.id}/opponent_individuals/new?locale=en">Opponents</a>
                </span>
                <strong class="govuk-tag govuk-tag--grey app-task-list__tag" id="opponent_name__status">Not started</strong>
              </li>
            RESULT
          end
          let(:opponent) { create(:opponent, :for_organisation, legal_aid_application:) }

          it "returns a link" do
            expect(helper.task_list_item(name: :opponent_name,
                                         status: :not_started,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end

        context "with an opponent already added" do
          let(:expected) do
            <<~RESULT
              <li class="app-task-list__item">
                <span class="app-task-list__task-name">
                    <a aria_describedby="opponent_name-status" aria-label="Opponents" href="/providers/applications/#{legal_aid_application.id}/has_other_opponent?locale=en">Opponents</a>
                </span>
                <strong class="govuk-tag app-task-list__tag" id="opponent_name__status">Completed</strong>
              </li>
            RESULT
          end

          it "returns a link" do
            create(:opponent, :for_individual, legal_aid_application:)
            expect(helper.task_list_item(name: :opponent_name,
                                         status: :complete,
                                         legal_aid_application:,
                                         ccms_code: nil)).to eq expected
          end
        end
      end
    end
  end
end
