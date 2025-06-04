# frozen_string_literal: true

module MojComponent
  class HeaderComponent < ViewComponent::Base
    attr_reader :organisation_name,
                :url,
                :nav_items

    def initialize(organisation_name:, url:, nav_items:)
      super
      @organisation_name = organisation_name
      @url = url
      @nav_items = nav_items
    end
  end
end
