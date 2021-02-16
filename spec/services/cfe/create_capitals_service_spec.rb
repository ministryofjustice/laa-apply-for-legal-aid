require 'rails_helper'

module CFE
  RSpec.describe CreateCapitalsService do
    let!(:application) { create :legal_aid_application, :with_applicant, with_bank_accounts: 6 }
    let!(:other_assets_declaration) { my_other_asset_declaration }
    # let!(:savings_amount) { my_savings_amount }
    let(:submission) { create :cfe_submission, aasm_state: 'applicant_created', legal_aid_application: application }
    let(:service) { described_class.new(submission) }
    let(:dummy_response) { dummy_response_hash.to_json }

    before do
      allow(application).to receive(:online_savings_accounts_balance).and_return(Faker::Number.decimal(l_digits: 3, r_digits: 2))
      allow(application).to receive(:online_current_accounts_balance).and_return(Faker::Number.decimal(l_digits: 3, r_digits: 2))
    end

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}/capitals"
      end
    end

    describe '#request payload' do
      let!(:savings_amount) { my_savings_amount }
      it 'creates the expected payload from the values in the applicant' do
        response_hash = JSON.parse(service.request_body, symbolize_names: true)
        response_hash.each_key do |key|
          expect(response_hash[key]).to match_array(expected_payload_hash[key])
        end
      end
    end

    describe '.call' do
      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      context 'successful post' do
        let!(:savings_amount) { my_savings_amount }
        before { stub_request(:post, service.cfe_url).with(body: expected_payload_hash.to_json).to_return(body: dummy_response) }

        it 'updates the submission record from applicant_created to capitals_created' do
          expect(submission.aasm_state).to eq 'applicant_created'
          CreateCapitalsService.call(submission)
          expect(submission.aasm_state).to eq 'capitals_created'
        end

        it 'creates a submission_history record' do
          expect {
            CreateCapitalsService.call(submission)
          }.to change { submission.submission_histories.count }.by 1
          history = CFE::SubmissionHistory.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq service.cfe_url
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload_hash.to_json
          expect(history.http_response_status).to eq 200
          expect(history.response_payload).to eq dummy_response
          expect(history.error_message).to be_nil
        end
      end

      describe 'failed calls to CFE' do
        it_behaves_like 'a failed call to CFE'
      end

      context 'nil current account on savings amount' do
        let!(:savings_amount) { savings_amount_with_nil_current_account }

        it 'does not send any data for current account' do
          stub_request(:post, service.cfe_url).with(body: expected_payload_without_current_account.to_json).to_return(body: dummy_response)
          expect(submission.aasm_state).to eq 'applicant_created'
          CreateCapitalsService.call(submission)
          expect(submission.aasm_state).to eq 'capitals_created'
        end
      end
    end

    def my_other_asset_declaration
      create :other_assets_declaration,
             :with_all_values,
             legal_aid_application: application,
             inherited_assets_value: nil,
             money_owed_value: 0.0
    end

    def my_savings_amount
      create :savings_amount,
             :with_values,
             legal_aid_application: application,
             plc_shares: nil,
             peps_unit_trusts_capital_bonds_gov_stocks: 0.0,
             life_assurance_endowment_policy: nil
    end

    def savings_amount_with_nil_current_account
      create :savings_amount,
             :with_values,
             legal_aid_application: application,
             offline_current_accounts: nil,
             plc_shares: nil,
             peps_unit_trusts_capital_bonds_gov_stocks: 0.0,
             life_assurance_endowment_policy: nil
    end

    def expected_payload_hash # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      payload = {
        bank_accounts: [
          {
            description: 'Current accounts',
            value: savings_amount.offline_current_accounts.to_s
          },
          {
            description: 'Savings accounts',
            value: savings_amount.offline_savings_accounts.to_s
          },
          {
            description: 'Money not in a bank account',
            value: savings_amount.cash.to_s
          },
          {
            description: "Access to another person's bank account",
            value: savings_amount.other_person_account.to_s
          },
          {
            description: 'ISAs, National Savings Certificates and Premium Bonds',
            value: savings_amount.national_savings.to_s
          }
        ],
        non_liquid_capital: [
          {
            description: 'Timeshare property',
            value: other_assets_declaration.timeshare_property_value.to_s
          },
          {
            description: 'Land',
            value: other_assets_declaration.land_value.to_s
          },
          {
            description: 'Any valuable items worth more than £500',
            value: other_assets_declaration.valuable_items_value.to_s
          },
          { description: 'Interest in a trust',
            value: other_assets_declaration.trust_value.to_s }
        ]
      }
      add_non_nil_accounts(payload, :current)
      add_non_nil_accounts(payload, :savings)
      payload
    end

    def add_non_nil_accounts(payload, account_type)
      case account_type
      when :current
        add_account(payload, 'Online current accounts', application.online_current_accounts_balance)
      when :savings
        add_account(payload, 'Online savings accounts', application.online_savings_accounts_balance)
      end
    end

    def add_account(payload, description, value)
      return if value.nil?

      payload[:bank_accounts] << { description: description, value: value }
    end

    def expected_payload_without_current_account
      hash = expected_payload_hash.clone
      hash[:bank_accounts].shift
      hash
    end

    def dummy_response_hash
      {
        success: true
      }
    end
  end
end
