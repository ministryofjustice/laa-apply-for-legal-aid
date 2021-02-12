# require 'rails_helper'
#
# RSpec.describe AddScopeLimitationService do
#   let(:legal_aid_application) { create :legal_aid_application, proceeding_types: [proceeding_type] }
#   let!(:proceeding_type) { create :proceeding_type }
#   let!(:sl_substantive_default) { create :scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type, meaning: 'Default substantive SL' }
#   let!(:sl_delegated_default) { create :scope_limitation, :delegated_functions_default, joined_proceeding_type: proceeding_type, meaning: 'Default delegated functions SL' }
#   let!(:sl_non_default) { create :scope_limitation }
#   let(:scope_type) { :delegated }
#
#   subject(:service) { described_class.call(legal_aid_application, scope_type) }
#
#   describe 'default_scope_limitation finding and adding' do
#     before { subject }
#     context 'substantive application' do
#       context '#substantive scope limitations' do
#         let(:scope_type) { :substantive }
#
#         describe 'substantive scope limitation' do
#           it 'returns the substantive scope limitation' do
#             expect(legal_aid_application.scope_limitations).to match_array [sl_substantive_default]
#             expect(legal_aid_application.substantive_scope_limitation).to eq sl_substantive_default
#           end
#         end
#       end
#     end
#
#     context 'delegated functions scope limitation' do
#       describe 'delegated functions scope limitation' do
#         it 'returns the delegated functions scope limitation' do
#           expect(legal_aid_application.scope_limitations).to match_array [sl_delegated_default]
#           expect(legal_aid_application.delegated_functions_scope_limitation).to eq sl_delegated_default
#         end
#       end
#     end
#   end
# end
