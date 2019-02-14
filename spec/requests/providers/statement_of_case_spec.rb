require 'rails_helper'

RSpec.describe 'provider proceedings before the court requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }
  let(:soc) { nil }

  describe 'GET providers/proceedings_before_the_court' do
    subject { get providers_legal_aid_application_statement_of_case_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        legal_aid_application.statement_of_case = soc
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not display error' do
        expect(response.body).not_to match 'id="statement-error"'
      end

      context 'no statement of case record exists for the application' do
        it 'displays an empty text box' do
          expect(legal_aid_application.statement_of_case).to be nil
          expect(response.body).to have_text_area_with_id_and_content('statement', '')
        end
      end

      context 'statement of case record already exists for the application' do
        let(:soc) { legal_aid_application.create_statement_of_case(statement: 'This is my case statement') }
        it 'displays the details of the statement on the page' do
          expect(response.body).to have_text_area_with_id_and_content('statement', soc.statement)
        end
      end
    end
  end

  describe 'PATCH providers/proceedings_before_the_court' do
    subject { patch providers_legal_aid_application_statement_of_case_path(legal_aid_application), params: params.merge(submit_button) }
    let(:entered_text) { Faker::Lorem.paragraph(3) }
    let(:original_file) { uploaded_file('spec/fixtures/files/lorem_ipsum.pdf', 'application/pdf') }

    let(:params) do
      {
        statement_of_case: {
          statement: entered_text,
          original_file: original_file
        }
      }
    end

    context 'when the provider is authenticated' do
      before { login_as provider }

      let(:submit_button) { {} }

      it 'updates the record' do
        subject
        expect(legal_aid_application.statement_of_case.reload.statement).to eq(entered_text)
        expect(legal_aid_application.statement_of_case.original_file.attachment).to be_present
      end

      it 'redirects to the next page' do
        subject
        expect(response).to redirect_to providers_legal_aid_application_estimated_legal_costs_path(legal_aid_application)
      end

      context 'file is empty but text is entered' do
        let(:original_file) { nil }

        it 'updates the statement text' do
          subject
          expect(legal_aid_application.statement_of_case.reload.statement).to eq(entered_text)
          expect(legal_aid_application.statement_of_case.original_file.attachment).not_to be_present
        end
      end

      context 'text is empty but file is present' do
        let(:entered_text) { '' }

        it 'updates the file' do
          subject
          expect(legal_aid_application.statement_of_case.reload.statement).to eq('')
          expect(legal_aid_application.statement_of_case.original_file.attachment).to be_present
        end
      end

      context 'file is invalid content type' do
        let(:original_file) { uploaded_file('spec/fixtures/files/zip.zip', 'application/zip') }

        it 'does not save the object and raise an error' do
          subject
          expect(response.body).to include(I18n.t('activemodel.errors.models.statement_of_case.attributes.original_file.content_type_invalid'))
          expect(legal_aid_application.statement_of_case).to be_nil
        end
      end

      context 'file is too big' do
        before { allow(StatementOfCases::StatementOfCaseForm).to receive(:max_file_size).and_return(0) }

        it 'does not save the object and raise an error' do
          subject
          expect(response.body).to include(I18n.t('activemodel.errors.models.statement_of_case.attributes.original_file.file_too_big', size: 0))
          expect(legal_aid_application.statement_of_case).to be_nil
        end
      end

      context 'file is empty' do
        let(:original_file) { uploaded_file('spec/fixtures/files/empty_file') }

        it 'does not save the object and raise an error' do
          subject
          expect(response.body).to include(I18n.t('activemodel.errors.models.statement_of_case.attributes.original_file.file_empty'))
          expect(legal_aid_application.statement_of_case).to be_nil
        end
      end

      context 'on error' do
        let(:entered_text) { '' }
        let(:original_file) { nil }

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'displays error' do
          subject
          expect(response.body).to match 'id="statement-error"'
        end

        context 'file contains a malware' do
          let(:original_file) { uploaded_file('spec/fixtures/files/malware.doc') }

          it 'does not save the object and raise an error' do
            subject
            expect(response.body).to include(I18n.t('activemodel.errors.models.statement_of_case.attributes.original_file.file_virus'))
            expect(legal_aid_application.statement_of_case).to be_nil
          end
        end
      end

      context 'Save as draft' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it 'updates the record' do
          subject
          expect(legal_aid_application.statement_of_case.reload.statement).to eq(entered_text)
          expect(legal_aid_application.statement_of_case.original_file.attachment).to be_present
        end

        it 'redirects to provider applications home page' do
          subject
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        context 'nothing specified' do
          let(:entered_text) { '' }
          let(:original_file) { nil }

          it 'redirects to provider applications home page' do
            subject
            expect(response).to redirect_to providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
