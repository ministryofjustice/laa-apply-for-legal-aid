module Providers
  module SaveAsDraftable
    extend ActiveSupport::Concern

    def continue_or_save_draft(continue_url: next_step_url, save_url: providers_legal_aid_applications_path)
      if params.key?(:continue_button)
        redirect_to continue_url
      elsif params.key?(:draft_button)
        redirect_to save_url
      else
        raise 'No Continue or Save as draft button when expected'
      end
    end
  end
end
