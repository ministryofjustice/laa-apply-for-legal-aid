require 'rails_helper'

RSpec.describe CFE::CreatePropertiesService do
  let(:property_value) { Faker::Number.number(digits: 6) }
  let(:outstanding_mortgage) { property_value / Faker::Number.number(digits: 2) }
  let(:percentage_owned) { Faker::Number.number(digits: 2) }
  let(:shared_ownership) { 'housing_assocation_or_landlord' }

  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      property_value: property_value,
      outstanding_mortgage_amount: outstanding_mortgage,
      percentage_home: percentage_owned,
      shared_ownership: shared_ownership
    )
  end
  let(:submission) do
    create :cfe_submission, assessment_id: SecureRandom.uuid, aasm_state: :vehicles_created
  end

  subject { described_class.new submission }

  describe '#call' do
    let(:api_response) { { success: true }.to_json }
    let(:response_status) { 200 }
    let(:submission_history) { submission.submission_histories.order(created_at: :asc).last }

    around do |example|
      VCR.turn_off!
      stub_request(:post, subject.cfe_url)
        .with(
          body: subject.request_body,
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: response_status,
          body: api_response
        )

      example.run
      VCR.turn_on!
    end

    it 'sends data to endpoint' do
      subject.call
    end

    it 'changes the submission state' do
      expect { subject.call }.to change { submission.reload.properties_created? }.from(false).to(true)
    end

    it 'generates a Submission History' do
      expect { subject.call }.to change { submission.submission_histories.count }.by(1)
      submission_history = submission.submission_histories.last
      expect(submission_history.response_payload).to eq(api_response)
    end

    context 'on failure' do
      let(:api_response) { { success: false }.to_json }
      let(:response_status) { 400 }
      let(:call_error) do
        expect { subject.call }.to raise_error(CFE::SubmissionError)
      end

      it 'does not change the submission state' do
        expect { call_error }.not_to change { submission.reload.aasm_state }
      end

      it 'generates a Submission History' do
        expect { call_error }.to change { submission.submission_histories.count }.by(1)
        expect(submission_history.response_payload).to eq(api_response)
      end
    end
  end

  describe '#request_body' do
    let(:request_body) { JSON.parse subject.request_body, symbolize_names: true }
    let(:additional_property) { request_body.dig(:properties, :additional_properties)&.first || {} }

    it 'contains main home data as zeros' do
      expect(request_body.dig(:properties, :main_home, :value).to_i).to be_zero
      expect(request_body.dig(:properties, :main_home, :outstanding_mortgage).to_i).to be_zero
      expect(request_body.dig(:properties, :main_home, :percentage_owned).to_i).to be_zero
    end

    it 'contains an empty additional home' do
      expect(additional_property[:value]).to be_zero
      expect(additional_property[:outstanding_mortgage]).to be_zero
      expect(additional_property[:percentage_owned]).to be_zero
    end

    it 'includes sharing data' do
      expect(request_body.dig(:properties, :main_home, :shared_with_housing_assoc)).to be(false)
      expect(additional_property[:shared_with_housing_assoc]).to be(false)
    end

    context 'with an own home' do
      let(:submission) do
        create(
          :cfe_submission,
          assessment_id: SecureRandom.uuid,
          legal_aid_application: legal_aid_application
        )
      end

      it 'contains the main home data' do
        expect(request_body.dig(:properties, :main_home, :value).to_i).to eq(property_value)
        expect(request_body.dig(:properties, :main_home, :outstanding_mortgage).to_i).to eq(outstanding_mortgage)
        expect(request_body.dig(:properties, :main_home, :percentage_owned).to_i).to eq(percentage_owned)
      end

      it 'contains an empty additional home' do
        expect(additional_property[:value]).to be_zero
        expect(additional_property[:outstanding_mortgage]).to be_zero
        expect(additional_property[:percentage_owned]).to be_zero
      end

      it 'includes sharing data' do
        expect(request_body.dig(:properties, :main_home, :shared_with_housing_assoc)).to be(true)
        expect(additional_property[:shared_with_housing_assoc]).to be(false)
      end
    end

    context 'with two properties' do
      let!(:other_assets_declaration) do
        create :other_assets_declaration, :with_second_home, legal_aid_application: legal_aid_application
      end
      let(:submission) do
        create(
          :cfe_submission,
          assessment_id: SecureRandom.uuid,
          legal_aid_application: legal_aid_application
        )
      end

      it 'contains the main home data' do
        expect(request_body.dig(:properties, :main_home, :value).to_i).to eq(property_value)
        expect(request_body.dig(:properties, :main_home, :outstanding_mortgage).to_i).to eq(outstanding_mortgage)
        expect(request_body.dig(:properties, :main_home, :percentage_owned).to_i).to eq(percentage_owned)
      end

      it 'contains an additional home data' do
        expect(additional_property[:value]).to eq(other_assets_declaration.second_home_value.to_s)
        expect(additional_property[:outstanding_mortgage]).to eq(other_assets_declaration.second_home_mortgage.to_s)
        expect(additional_property[:percentage_owned]).to eq(other_assets_declaration.second_home_percentage.to_s)
      end

      it 'includes sharing data' do
        expect(request_body.dig(:properties, :main_home, :shared_with_housing_assoc)).to be(true)
        expect(additional_property[:shared_with_housing_assoc]).to be(false)
      end
    end
  end

  describe 'cfe_url' do
    it 'points to properties end point' do
      expect(subject.cfe_url).to match(%r{assessments/#{submission.assessment_id}/properties$})
    end
  end
end
