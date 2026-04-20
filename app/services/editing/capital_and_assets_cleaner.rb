module Editing
  class CapitalAndAssetsCleaner
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def call
      # rubocop:disable Rails/Output
      puts "deleting capital and assets data for legal aid application #{legal_aid_application.id}"
      # rubocop:enable Rails/Output
    end

  private

    attr_reader :legal_aid_application
  end
end
