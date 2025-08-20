module V1
  class AttachmentsController < ApiController
    def update
      return head :not_found unless attachment

      attachment.update!(attachment_type: attachment_params[:type])
      head :ok
    rescue ActiveRecord::RecordInvalid
      head :bad_request
    end

  private

    def attachment
      return @attachment if defined?(@attachment)

      @attachment = Attachment.find_by(id: params[:id])
    end

    def attachment_params
      params.expect(attachment: [:type])
    end
  end
end
