require 'rails_helper'

RSpec.describe DigestExporter do
  around do |example|
    example.run
  end

  describe '.call' do
    let(:record_id) {  '26984944-a5c4-47f3-9c8d-39d6e03e3283' }
    let(:firm_name) { 'Mayer, Bashirian and Frami' }
    let(:provider_username) { 'finchy' }
    let(:date_started) { Date.new(2021, 11, 9) }
    let(:date_submitted) { Date.new(2021, 11, 11) }
    let(:days_to_submission) { 3 }
    let(:use_ccms) { false }
    let(:matter_types) { 'Domestic Abuse;Section 8 orders' }
    let(:proceedings) { 'DA001;SE013;SE014' }
    let(:passported) { false }
    let(:df_used) { true }
    let(:earliest_df_date) { Date.new(2021, 11, 5) }
    let(:df_reported_date) { Date.new(2021, 11, 9) }
    let(:working_days_to_report_df) { 5 }
    let(:working_days_to_submit_df) { 7 }


    before do
      fill_spreadsheet_with_dummy_data
      create_list :application_digest, 4
      create_specific_application_digest
      described_class.call
    end

    it 'puts column headers in first row' do
      VCR.use_cassette 'DigestExporter/call/column_headers_in_first_row' do
        expect(first_row).to eq ApplicationDigest.column_headers
      end
    end

    it 'reduces the number of rows int he spreadsheet from 8 to 6' do
      VCR.use_cassette 'DigestExporter/call/reduces_rows' do
        expect(number_of_rows).to eq 6
      end
    end

    it 'populates the cells with the expected values' do
      VCR.use_cassette 'DigestExporter/call/populates' do
        row = get_specific_applicaiton_digest_row
        expect(row[0]).to eq record_id
        expect(row[1]).to eq firm_name
        expect(row[2]).to eq provider_username
        expect(row[3]).to eq date_started.strftime('%-d %B %Y')
        expect(row[4]).to eq date_submitted.strftime('%-d %B %Y')
        expect(row[5]).to eq days_to_submission.to_s
        expect(row[6]).to eq use_ccms.to_s.upcase
        expect(row[7]).to eq matter_types
        expect(row[8]).to eq proceedings
        expect(row[9]).to eq passported.to_s.upcase
        expect(row[10]).to eq df_used.to_s.upcase
        expect(row[11]).to eq earliest_df_date.strftime('%-d %B %Y')
        expect(row[12]).to eq df_reported_date.strftime('%-d %B %Y')
        expect(row[13]).to eq working_days_to_report_df.to_s
        expect(row[14]).to eq working_days_to_submit_df.to_s
      end
    end

    def fill_spreadsheet_with_dummy_data
      worksheet = initialize_worksheet
      worksheet.update_cells(1, 1, initial_dummy_data)
      worksheet.save
    end

    def first_row
      worksheet = initialize_worksheet
      worksheet.rows[0]
    end

    def number_of_rows
      worksheet = initialize_worksheet
      worksheet.max_rows
    end

    def get_specific_applicaiton_digest_row
      worksheet = initialize_worksheet
      rows = worksheet.rows[0, worksheet.max_rows]
      rows.detect { |row| row.first == record_id}
    end

    def initialize_worksheet
      secret_file = StringIO.new(google_secret.to_json)
      session = GoogleDrive::Session.from_service_account_key(secret_file)
      session.spreadsheet_by_key(Rails.configuration.x.digest_export.spreadsheet_id).worksheets[0]
    end

    def initial_dummy_data
      [
        %w[1 aaa bbb ccc ddd eee fff ggg hhh],
        %w[2 aaa bbb ccc ddd eee fff ggg hhh],
        %w[3 aaa bbb ccc ddd eee fff ggg hhh],
        %w[4 aaa bbb ccc ddd eee fff ggg hhh],
        %w[5 aaa bbb ccc ddd eee fff ggg hhh],
        %w[6 aaa bbb ccc ddd eee fff ggg hhh],
        %w[7 aaa bbb ccc ddd eee fff ggg hhh],
        %w[8 aaa bbb ccc ddd eee fff ggg hhh],
      ]
    end

    def google_secret
      {
        type: 'service_account',
        project_id: 'laa-apply-for-legal-aid',
        private_key_id: ENV['GOOGLE_SHEETS_PRIVATE_KEY_ID'],
        private_key: ENV['GOOGLE_SHEETS_PRIVATE_KEY'],
        client_email: ENV['GOOGLE_SHEETS_CLIENT_EMAIL'],
        client_id: ENV['109643562093060480241'],
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: 'https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com'
      }
    end

    def create_specific_application_digest
      ApplicationDigest.create!(
        legal_aid_application_id: record_id,
        firm_name: firm_name,
        provider_username: provider_username,
        date_started: date_started,
        date_submitted: date_submitted,
        days_to_submission: days_to_submission,
        use_ccms: use_ccms,
        matter_types: matter_types,
        proceedings: proceedings,
        passported: passported,
        df_used: df_used,
        earliest_df_date: earliest_df_date,
        df_reported_date: df_reported_date,
        working_days_to_report_df: working_days_to_report_df,
        working_days_to_submit_df: working_days_to_submit_df
      )
    end
  end
end

