module V1
  class StatementOfCasesController < ApiController
    def create
      legal_aid_application = LegalAidApplication.find_by(id: params[:legal_aid_application_id])
      legal_aid_application.attachments.create document: uploaded_file,
                                               attachment_type: name,
                                               original_filename: uploaded_file.filename,
                                               attachment_name: sequenced_attachment_name
      render '', status: :ok
    end

    def destroy
      legal_aid_application = LegalAidApplication.find_by(id: params[:id])
      if legal_aid_application
        legal_aid_application.discard
        legal_aid_application.scheduled_mailings.map(&:cancel!)

        render '', status: :ok
      else
        render '', status: :not_found
      end
    end
  end
end
