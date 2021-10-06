require 'rails_helper'

RSpec.describe Proceeding, type: :model do
  it {
    is_expected.to respond_to(:legal_aid_application_id,
                              :proceeding_case_id,
                              :lead_proceeding,
                              :ccms_code,
                              :meaning,
                              :description,
                              :substantive_cost_limitation,
                              :delegated_functions_cost_limitation,
                              :substantive_scope_limitation_code,
                              :substantive_scope_limitation_meaning,
                              :substantive_scope_limitation_description,
                              :delegated_functions_scope_limitation_code,
                              :delegated_functions_scope_limitation_meaning,
                              :delegated_functions_scope_limitation_description,
                              :used_delegated_functions_on,
                              :used_delegated_functions_reported_on)
  }
end
