require 'rails_helper'

RSpec.describe TaskListHelper, type: :helper do
  context 'when passed an application with section 8 proceeding_types' do
    let(:legal_aid_application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }
    context 'with a child already added' do
      before { create :involved_child, legal_aid_application: legal_aid_application }

      let(:expected) do
        <<~RESULT
          <li class="app-task-list__item">
            <span class="app-task-list__task-name">
                <a aria_describedby="children_application-status" title="Children involved in this application" aria-label="Children involved in this application" href="/providers/applications/#{legal_aid_application.id}/has_other_involved_children?locale=en">Children involved in this application</a>
            </span>
            <strong class="govuk-tag  app-task-list__tag" id="children_application_status">Completed</strong>
          </li>
        RESULT
      end

      it 'returns a link' do
        expect(helper.task_list_item(name: :children_application,
                                     status: :complete,
                                     legal_aid_application: legal_aid_application,
                                     ccms_code: nil)).to eq expected
      end
    end

    context 'with no child added' do
      let(:expected) do
        <<~RESULT
          <li class="app-task-list__item">
            <span class="app-task-list__task-name">
                <a aria_describedby="children_application-status" title="Children involved in this application" aria-label="Children involved in this application" href="/providers/applications/#{legal_aid_application.id}/involved_children/new?locale=en">Children involved in this application</a>
            </span>
            <strong class="govuk-tag govuk-tag--grey app-task-list__tag" id="children_application_status">Not started</strong>
          </li>
        RESULT
      end

      it 'returns a link' do
        expect(helper.task_list_item(name: :children_application,
                                     status: :not_started,
                                     legal_aid_application: legal_aid_application,
                                     ccms_code: nil)).to eq expected
      end
    end
  end
end
