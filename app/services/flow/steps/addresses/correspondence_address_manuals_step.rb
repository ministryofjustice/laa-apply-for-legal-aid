module Flow
  module Steps
    module Addresses
      CorrespondenceAddressManualsStep = Step.new(
        forward: lambda do |application|
          if Setting.home_address?
            :different_addresses
          elsif Setting.linked_applications?
            :link_application_make_links
          else
            application.proceedings.any? ? :has_other_proceedings : :proceedings_types
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end