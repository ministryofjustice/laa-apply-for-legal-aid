module Editing
  class PostMeritsDataCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      legal_aid_application.update!(client_declaration_confirmed_at: nil)
      # TODO: maybe delete means and merits reports if they exist
    end

  private

    attr_reader :legal_aid_application
  end
end
