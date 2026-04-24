module Editing
  class PostMeritsDataCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      # rubocop:disable Rails/Output
      puts "deleting post-merits data for legal aid application #{legal_aid_application.id}"
      # rubocop:enable Rails/Output
      legal_aid_application.update!(client_declaration_confirmed_at: nil)
    end

  private

    attr_reader :legal_aid_application
  end
end
