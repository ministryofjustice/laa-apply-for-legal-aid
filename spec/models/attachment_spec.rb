require 'rails_helper'

RSpec.describe Attachment do
  context 'validation' do
    let(:laa) { create :legal_aid_application }
    let(:invalid_attachment_type) { 'invalid_type' }
    let(:valid_attachment_types) do
      %w[
        statement_of_case
        statement_of_case_pdf
        merits_report
        means_report
        bank_transaction_report
        gateway_evidence
        gateway_evidence_pdf
      ]
    end

    subject { Attachment.create! legal_aid_application: laa, attachment_type: attachment_type }

    context 'valid attachment types' do
      let(:attachment_type) { valid_attachment_types.sample }
      it 'does not fail when trying to create a record with an invalid attachment type' do
        expect { subject }.not_to raise_error ArgumentError
      end
    end

    context 'invalid attachment type' do
      let(:attachment_type) { invalid_attachment_type }
      it 'fails when trying to create a record with an invalid attachment type' do
        expect { subject }.to raise_error ArgumentError, "'invalid_type' is not a valid attachment_type"
      end
    end
  end
end
