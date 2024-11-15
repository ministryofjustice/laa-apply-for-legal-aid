module V1
  class AttachmentsController < ApiController
    def update
      return head :not_found unless attachment

      attachment.update!(attachment_type: form_params[:attachment_type])
      head :ok
    end

  private

    def attachment
      @attachment ||= Attachment.find_by(id: form_params[:attachment_id])
    end

    def form_params
      params.permit(%i[attachment_id attachment_type])
    end
  end
end
