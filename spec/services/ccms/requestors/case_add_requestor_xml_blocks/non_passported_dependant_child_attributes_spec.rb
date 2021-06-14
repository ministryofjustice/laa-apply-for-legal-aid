require 'rails_helper'

module CCMS
  module Requestors # rubocop:disable Metrics/ModuleLength
    RSpec.describe NonPassportedCaseAddRequestor do
      context 'XML request' do
        let(:expected_tx_id) { '201904011604570390059770666' }
        let(:firm) { create :firm, name: 'Firm1' }
        let(:office) { create :office, firm: firm }
        let(:savings_amount) { legal_aid_application.savings_amount }
        let(:other_assets_decl) { legal_aid_application.other_assets_declaration }
        let(:provider) do
          create :provider,
                 firm: firm,
                 selected_office: office,
                 username: 4_953_649
        end

        let(:legal_aid_application) do
          create :legal_aid_application,
                 :with_everything,
                 :with_applicant_and_address,
                 :with_negative_benefit_check_result,
                 :with_proceeding_types,
                 :with_chances_of_success,
                 populate_vehicle: true,
                 with_bank_accounts: 2,
                 provider: provider,
                 office: office
        end

        let!(:child_dependants) { create_list :dependant, 2, :under18, legal_aid_application: legal_aid_application }
        let!(:adult_dependants) { create_list :dependant, 2, :over18, legal_aid_application: legal_aid_application }


        let(:ccms_reference) { '300000054005' }
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: ccms_reference }
        let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
        let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }
        let(:requestor) { described_class.new(submission, {}) }
        let(:xml) { requestor.formatted_xml }

        it 'generates the expected block for each of the hard coded attrs' do
          puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
          puts xml
          puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
          hard_coded_attrs.each do |attr|
            entity, attr_name, type, user_defined, value = attr
            block = XmlExtractor.call(xml, entity.to_sym, attr_name)
            case type
            when 'number'
              expect(block).to have_number_response value.to_i
            when 'text'
              expect(block).to have_text_response value
            when 'currency'
              expect(block).to have_currency_response value
            when 'date'
              expect(block).to have_date_response value
            else raise 'Unexpected type'
            end

            case user_defined
            when true
              expect(block).to be_user_defined
            else
              expect(block).not_to be_user_defined
            end
          end
        end

        def hard_coded_attrs
          [
            ['client_residing_person', 'CLI_RES_PER_INPUT_B_12WP3_20A', 'boolean', false, false]
          ]
        end
      end
    end
  end
end
