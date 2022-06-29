module V1
  class StatementOfCasesController < ApiController
    include MalwareScanning
    ATTACHMENT_TYPE = "statement_of_case".freeze

    def create
      return head :not_found unless legal_aid_application

      file = form_params[:file]

      malware_scan = malware_scan_result(file)
      return render json: { error: original_file_error_for(:file_virus, file_name: file.original_filename) }, status: :bad_request if malware_scan.virus_found?
      return render json: { error: original_file_error_for(:system_down) }, status: :bad_request unless malware_scan.scanner_working

      if legal_aid_application.statement_of_case.nil?
        legal_aid_application.create_statement_of_case(statement: extract_text(file))
      else
        legal_aid_application.statement_of_case.update(statement: extract_text(file))
      end
      legal_aid_application.attachments.create document: file,
                                               attachment_type: ATTACHMENT_TYPE,
                                               original_filename: file.original_filename,
                                               attachment_name: sequenced_attachment_name
      head :ok
    end

  private

    def provider_uploader
      legal_aid_application.provider
    end

    def extract_text(file)
      path = get_file_path(file)

      image = RTesseract.new(path, { psm: 1 })
      image.to_s
    rescue StandardError => e
      Rails.logger.info e.message
      ""
    end

    def get_file_path(file)
      case file.content_type
      when "application/pdf"
        convert_pdf_return_path(file)
      when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        raise "Currently unsupported"
      else
        # just use temp upload path
        file.tempfile.path.to_s
      end
    end

    def convert_pdf_return_path(uploaded_file)
      in_path = uploaded_file.path
      out_path = "#{in_path}--all-pages.png"
      im = Magick::ImageList.new(in_path) do |pdf|
        pdf.format = "PDF"
        pdf.density = 288
        pdf.quality = 85
      end
      result = im.append(true).write(out_path)
      result.filename
    end

    def error_path
      "application_merits_task/statement_of_case"
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find_by(id: form_params[:legal_aid_application_id])
    end

    def form_params
      params.permit(%i[legal_aid_application_id file])
    end

    def sequenced_attachment_name
      if legal_aid_application.attachments.statement_of_case.any?
        most_recent_name = legal_aid_application.attachments.statement_of_case.order(:attachment_name).last.attachment_name
        increment_name(most_recent_name)
      else
        ATTACHMENT_TYPE
      end
    end

    def increment_name(most_recent_name)
      name = ATTACHMENT_TYPE
      if most_recent_name == name
        "#{name}_1"
      else
        most_recent_name =~ /^#{name}_(\d+)$/
        "#{name}_#{Regexp.last_match(1).to_i + 1}"
      end
    end
  end
end
