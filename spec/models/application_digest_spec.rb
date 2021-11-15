require 'rails_helper'

RSpec.describe ApplicationDigest do
  describe '.create_or_update!' do
    around do |example|
      enable_apt_callbacks
      example.run
      disable_apt_callbacks
    end

    let(:firm_name) { 'Regional Legal Services' }
    let(:username) { 'regional_user_1' }
    let(:firm) { create :firm, name: firm_name }
    let(:provider) { create :provider, firm: firm, username: username }
    let(:creation_time) { Time.zone.local(2019, 1, 1, 12, 15, 30) }
    let(:creation_date) { creation_time.to_date }
    let(:submission_time) { creation_time + 3.days }
    let(:submission_date) { submission_time.to_date }
    let(:da001) { create :proceeding_type, :da001, :with_scope_limitations }
    let(:se013) { create :proceeding_type, :se013, :with_scope_limitations }
    let(:se014) { create :proceeding_type, :se014, :with_scope_limitations }

    let(:laa) do
      travel_to creation_time do
        create :legal_aid_application,
               :assessment_submitted,
               :with_everything,
               :with_proceeding_types,
               explicit_proceeding_types: [da001, se013, se014],
               provider: provider,
               merits_submitted_at: submission_time
      end
    end
    let(:laa_at_use_ccms) { create :legal_aid_application, :use_ccms }

    let(:digest) { described_class.find_by(legal_aid_application_id: laa.id) }

    subject { described_class.create_or_update!(laa.id) }

    context 'when a digest record already exists for this application' do
      before { create :application_digest, legal_aid_application_id: laa.id }

      it 'does not create a new record' do
        expect { subject }.not_to change { ApplicationDigest.count }
      end

      it 'updates the values on the existing record' do
        subject
        expect(digest.firm_name).to eq firm_name
        expect(digest.provider_username).to eq username
        expect(digest.date_started).to eq creation_date
        expect(digest.date_submitted).to eq submission_date
        expect(digest.days_to_submission).to eq 4
        expect(digest.matter_types).to eq 'Domestic Abuse;Section 8 orders'
        expect(digest.proceedings).to eq 'DA001;SE013;SE014'
      end
    end

    context 'when no digest record exists for this application' do
      it 'creates a new record' do
        expect { subject }.to change { ApplicationDigest.count }.by(1)
      end

      it 'creates a record with expected values' do
        subject
        expect(digest.firm_name).to eq firm_name
        expect(digest.provider_username).to eq username
        expect(digest.date_started).to eq creation_date
        expect(digest.date_submitted).to eq submission_date
        expect(digest.days_to_submission).to eq 4
        expect(digest.matter_types).to eq 'Domestic Abuse;Section 8 orders'
        expect(digest.proceedings).to eq 'DA001;SE013;SE014'
      end
    end

    context 'use_ccms' do
      context 'application is not at use_ccms' do
        it 'is false' do
          subject
          expect(digest.use_ccms).to be false
        end
      end

      context 'applcation is at use_ccms' do
        it 'is true' do
          described_class.create_or_update!(laa_at_use_ccms.id)
          digest = described_class.find_by(legal_aid_application_id: laa_at_use_ccms.id)
          expect(digest.use_ccms).to be true
        end
      end
    end

    context 'passported' do
      context 'application is passported' do
        before do
          expect_any_instance_of(LegalAidApplication).to receive(:passported?).and_return(true)
          subject
        end

        it 'returns true' do
          expect(digest.passported).to be true
        end
      end

      context 'application is NOT passported' do
        before do
          expect_any_instance_of(LegalAidApplication).to receive(:passported?).and_return(false)
          subject
        end

        it 'returns true' do
          expect(digest.passported).to be false
        end
      end
    end

    context 'delegated_functions' do
      context 'delegated_functions not used' do
        it 'returns false and nils' do
          subject
          expect(digest.df_used).to be false
          expect(digest.earliest_df_date).to be_nil
          expect(digest.df_reported_date).to be_nil
          expect(digest.working_days_to_report_df).to be_nil
        end
      end

      context 'delegated_functions used' do
        before do
          # DF used on DA001 and SE014 only - used and reported dates specified in array
          # Good Friday on 2nd April, Easter Monday 5th April
          # We update the application_proceeding_types here, and rely on the callbacks to update the Proceedings
          dates = {
            'DA001' => [Date.parse('2021-03-29'), Date.parse('2021-04-08')],
            'SE013' => [nil, nil],
            'SE014' => [Date.parse('2021-04-06'), Date.parse('2021-04-07')]
          }
          laa.application_proceeding_types.each do |apt|
            used_date, reported_date = dates[apt.proceeding_type.ccms_code]
            apt.update!(used_delegated_functions_on: used_date, used_delegated_functions_reported_on: reported_date)
          end
          laa.reload
        end

        # for some reason, just running the test with VCR_RECORD_MODE=all would not create the cassette, so have to do it manually here
        it 'returns true and dates' do
          VCR.use_cassette 'ApplicationDigest/create_or_update/delegated_functions/delegated_functions_used/returns_true_and_dates' do
            subject
            expect(digest.df_used).to be true
            expect(digest.earliest_df_date).to eq Date.parse('2021-03-29')
            expect(digest.df_reported_date).to eq Date.parse('2021-04-08')
            expect(digest.working_days_to_report_df).to eq 7
          end
        end
      end
    end
  end
end
