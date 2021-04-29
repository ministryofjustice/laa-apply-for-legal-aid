require 'rails_helper'

RSpec.describe Reports::ReportsTypesCreator do
  let(:firm) { create :firm }
  let(:provider) { create :provider, firm: firm }
  let!(:application_non_passported) do
    create :legal_aid_application,
           :with_everything,
           # :with_proceeding_types,
           :at_assessment_submitted,
           :with_negative_benefit_check_result,
           :with_ccms_submission_completed,
           provider: provider
  end
  let!(:application_passported) do
    create :legal_aid_application,
           :with_everything,
           # :with_proceeding_types,
           :at_assessment_submitted,
           :with_positive_benefit_check_result,
           provider: provider
  end

  let(:report) { Reports::ReportsTypesCreator.call(params) }

  describe 'all application types' do
    context 'matching application' do
      let(:params) do
        {
          application_type: 'A',
          submitted_to_ccms: 'false',
          capital_assessment_result: ['eligible'],
          records_from_3i: '',
          records_from_2i: '',
          records_from_1i: '',
          records_to_3i: '',
          records_to_2i: '',
          records_to_1i: '',
          payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
        }
      end

      context 'generated csv' do
        let(:today) { Date.current }
        let(:yesterday) { today - 1.day }
        let(:two_days_ago) { today - 2.days }

        before do
          @table = CSV.parse(report.generate_csv, headers: true)
        end

        it 'has the correct headers' do
          expect(@table.headers).to eql(%w[application_ref case_ccms_reference COUNTRY APPLY_CASE_MEANS_REVIEW])
        end

        it 'has the correct application reference' do
          expect(@table.first['application_ref']).to include(application_non_passported.application_ref)
        end

        it 'has the correct case ccms reference' do
          ccms_record = CCMS::Submission.find_by(legal_aid_application_id: application_non_passported.id)
          expect(@table.first['case_ccms_reference']).to include(ccms_record.case_ccms_reference)
        end

        context 'in date range' do
          let(:params) do
            {
              application_type: 'A',
              submitted_to_ccms: 'false',
              capital_assessment_result: ['eligible'],
              records_from_3i: two_days_ago.year.to_s,
              records_from_2i: two_days_ago.month.to_s,
              records_from_1i: two_days_ago.day.to_s,
              records_to_3i: today.year.to_s,
              records_to_2i: today.month.to_s,
              records_to_1i: today.day.to_s,
              payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
            }
          end

          it 'has both records' do
            expect(@table.count).to eql(2)
          end
        end

        context 'outside date range' do
          let(:params) do
            {
              application_type: 'A',
              submitted_to_ccms: 'false',
              capital_assessment_result: ['eligible'],
              records_from_3i: two_days_ago.year.to_s,
              records_from_2i: two_days_ago.month.to_s,
              records_from_1i: two_days_ago.day.to_s,
              records_to_3i: yesterday.year.to_s,
              records_to_2i: yesterday.month.to_s,
              records_to_1i: yesterday.day.to_s,
              payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
            }
          end

          it 'has no records' do
            expect(@table).to be_empty
          end
        end

        context 'passported only' do
          let(:params) do
            {
              application_type: 'P',
              submitted_to_ccms: 'false',
              capital_assessment_result: ['eligible'],
              records_from_3i: '',
              records_from_2i: '',
              records_from_1i: '',
              records_to_3i: '',
              records_to_2i: '',
              records_to_1i: '',
              payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
            }
          end

          it 'has one passported record' do
            expect(@table.count).to eql(1)
            expect(@table.first['application_ref']).to include(application_passported.application_ref)
          end
        end

        context 'non passported only' do
          let(:params) do
            {
              application_type: 'NP',
              submitted_to_ccms: 'false',
              capital_assessment_result: ['eligible'],
              records_from_3i: '',
              records_from_2i: '',
              records_from_1i: '',
              records_to_3i: '',
              records_to_2i: '',
              records_to_1i: '',
              payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
            }
          end

          it 'has one passported record' do
            expect(@table.count).to eql(1)
            expect(@table.first['application_ref']).to include(application_non_passported.application_ref)
          end
        end

        context 'submitted to ccms' do
          let(:params) do
            {
              application_type: 'A',
              submitted_to_ccms: 'true',
              capital_assessment_result: ['eligible'],
              records_from_3i: '',
              records_from_2i: '',
              records_from_1i: '',
              records_to_3i: '',
              records_to_2i: '',
              records_to_1i: '',
              payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
            }
          end

          it 'collects records successfully sent to ccms only' do
            expect(@table.count).to eql(1)
            expect(@table.first['application_ref']).to include(application_non_passported.application_ref)
          end

          it 'extracts XML attributes listed by the user' do
            expect(@table.first['COUNTRY']).to include('GBR')
            expect(@table.first['APPLY_CASE_MEANS_REVIEW']).to include('false')
          end
        end
      end
    end

    context 'no matches' do
      let(:params) do
        {
          application_type: 'A',
          submitted_to_ccms: 'false',
          capital_assessment_result: ['pending'],
          records_from_3i: '',
          records_from_2i: '',
          records_from_1i: '',
          records_to_3i: '',
          records_to_2i: '',
          records_to_1i: '',
          payload_attrs: "country\r\nAPPLY_CASE_MEANS_REVIEW"
        }
      end

      it 'does not generate a csv report' do
        table = CSV.parse(report.generate_csv, headers: true)
        expect(table).to be_empty
      end
    end
  end
end
