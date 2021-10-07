require 'rails_helper'

RSpec.describe ProceedingsConverter do
  let(:converter) { described_class.new }

  describe '.call' do
    context 'single legal aid application' do
      context 'with a single application_proceeding_type' do
        let!(:laa) { create :legal_aid_application, :with_proceeding_types }
        let(:laa_proc) { laa.application_proceeding_types.first }
        let(:proceeding_records_for_application) { Proceeding.where(legal_aid_application_id: laa.id) }

        it 'creates a single proceeding record' do
          expect { converter.call }.to change { Proceeding.count }.by(1)
        end

        it 'the proceeding record is linked to the application' do
          converter.call

          expect(proceeding_records_for_application.count).to eq(1)
        end

        it 'populates the proceeding record with the correct data' do
          converter.call

          expect(proceeding_records_for_application.first.legal_aid_application_id).to eq laa.id
          expect(proceeding_records_for_application.first.proceeding_case_id).to eq laa_proc.proceeding_case_id
          expect(proceeding_records_for_application.first.lead_proceeding).to eq laa_proc.lead_proceeding
          expect(proceeding_records_for_application.first.ccms_code).to eq laa_proc.proceeding_type.ccms_code
          expect(proceeding_records_for_application.first.meaning).to eq laa_proc.proceeding_type.meaning
          expect(proceeding_records_for_application.first.description).to eq laa_proc.proceeding_type.description
          expect(proceeding_records_for_application.first.substantive_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_substantive
          expect(proceeding_records_for_application.first.delegated_functions_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_delegated_functions
          expect(proceeding_records_for_application.first.substantive_scope_limitation_code).to eq(
            laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.code
          )
          expect(proceeding_records_for_application.first.substantive_scope_limitation_meaning).to eq(
            laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.meaning
          )
          expect(proceeding_records_for_application.first.substantive_scope_limitation_description).to eq(
            laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.description
          )
          expect(proceeding_records_for_application.first.delegated_functions_scope_limitation_code).to eq(
            laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.code
          )
          expect(proceeding_records_for_application.first.delegated_functions_scope_limitation_meaning).to eq(
            laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.meaning
          )
          expect(proceeding_records_for_application.first.delegated_functions_scope_limitation_description).to eq(
            laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.description
          )
          expect(proceeding_records_for_application.first.used_delegated_functions_on).to eq laa_proc.used_delegated_functions_on
          expect(proceeding_records_for_application.first.used_delegated_functions_reported_on).to eq laa_proc.used_delegated_functions_reported_on
        end
      end

      context 'with multiple application_proceeding_types' do
        let(:proceeding_types_count) { 3 }
        let!(:laa) { create :legal_aid_application, :with_proceeding_types, proceeding_types_count: proceeding_types_count }
        let(:laa_proc) { laa.application_proceeding_types.first }
        let(:proceeding_records_for_application) { Proceeding.where(legal_aid_application_id: laa.id) }

        it 'creates one proceeding record for every application_proceeding_type' do
          expect { converter.call }.to change { Proceeding.count }.by(proceeding_types_count)
        end

        it 'all proceeding records are linked to the application' do
          converter.call

          expect(proceeding_records_for_application.count).to eq(proceeding_types_count)
        end

        it 'populates each proceeding record with the correct data' do
          converter.call

          proceeding_records_for_application.order(:created_at).each_with_index do |proceeding, index|
            laa_proc = laa.application_proceeding_types[index]

            expect(proceeding.legal_aid_application_id).to eq laa.id
            expect(proceeding.proceeding_case_id).to eq laa_proc.proceeding_case_id
            expect(proceeding.lead_proceeding).to eq laa_proc.lead_proceeding
            expect(proceeding.ccms_code).to eq laa_proc.proceeding_type.ccms_code
            expect(proceeding.meaning).to eq laa_proc.proceeding_type.meaning
            expect(proceeding.description).to eq laa_proc.proceeding_type.description
            expect(proceeding.substantive_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_substantive
            expect(proceeding.delegated_functions_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_delegated_functions
            expect(proceeding.substantive_scope_limitation_code).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.code
            )
            expect(proceeding.substantive_scope_limitation_meaning).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.meaning
            )
            expect(proceeding.substantive_scope_limitation_description).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.description
            )
            expect(proceeding.delegated_functions_scope_limitation_code).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.code
            )
            expect(proceeding.delegated_functions_scope_limitation_meaning).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.meaning
            )
            expect(proceeding.delegated_functions_scope_limitation_description).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.description
            )
            expect(proceeding.used_delegated_functions_on).to eq laa_proc.used_delegated_functions_on
            expect(proceeding.used_delegated_functions_reported_on).to eq laa_proc.used_delegated_functions_reported_on
          end
        end
      end
    end

    context 'with multiple applications with application_proceeding_types' do
      let(:proceeding_types_count) { 3 }
      let!(:laa) { create :legal_aid_application, :with_proceeding_types, proceeding_types_count: proceeding_types_count }
      let!(:laa2) { create :legal_aid_application, :with_proceeding_types, proceeding_types_count: proceeding_types_count }
      let!(:laa3) { create :legal_aid_application, :with_proceeding_types, proceeding_types_count: proceeding_types_count }

      it 'creates one proceeding record for every application_proceeding_type' do
        expect { converter.call }.to change { Proceeding.count }.by(proceeding_types_count * LegalAidApplication.count)
      end

      it 'all proceeding records are linked to the correct application' do
        converter.call

        LegalAidApplication.all.each do |application|
          proceeding_records_for_application = Proceeding.where(legal_aid_application_id: application.id)

          expect(proceeding_records_for_application.count).to eq(proceeding_types_count)
        end
      end

      it 'populates each proceeding record with the correct data' do
        converter.call

        LegalAidApplication.all.each do |application|
          proceeding_records_for_application = Proceeding.where(legal_aid_application_id: application.id)

          proceeding_records_for_application.order(:created_at).each_with_index do |proceeding, index|
            laa_proc = application.application_proceeding_types[index]

            expect(proceeding.legal_aid_application_id).to eq application.id
            expect(proceeding.proceeding_case_id).to eq laa_proc.proceeding_case_id
            expect(proceeding.lead_proceeding).to eq laa_proc.lead_proceeding
            expect(proceeding.ccms_code).to eq laa_proc.proceeding_type.ccms_code
            expect(proceeding.meaning).to eq laa_proc.proceeding_type.meaning
            expect(proceeding.description).to eq laa_proc.proceeding_type.description
            expect(proceeding.substantive_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_substantive
            expect(proceeding.delegated_functions_cost_limitation).to eq laa_proc.proceeding_type.default_cost_limitation_delegated_functions
            expect(proceeding.substantive_scope_limitation_code).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.code
            )
            expect(proceeding.substantive_scope_limitation_meaning).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.meaning
            )
            expect(proceeding.substantive_scope_limitation_description).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(substantive_default: true).first.scope_limitation.description
            )
            expect(proceeding.delegated_functions_scope_limitation_code).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.code
            )
            expect(proceeding.delegated_functions_scope_limitation_meaning).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.meaning
            )
            expect(proceeding.delegated_functions_scope_limitation_description).to eq(
              laa_proc.proceeding_type.proceeding_type_scope_limitations.where(delegated_functions_default: true).first.scope_limitation.description
            )
            expect(proceeding.used_delegated_functions_on).to eq laa_proc.used_delegated_functions_on
            expect(proceeding.used_delegated_functions_reported_on).to eq laa_proc.used_delegated_functions_reported_on
          end
        end
      end

      it 'does not create a duplicate record if a proceeding record already exist' do
        converter.call
        expect { converter.call }.not_to change { Proceeding.count }
      end
    end
  end
end
