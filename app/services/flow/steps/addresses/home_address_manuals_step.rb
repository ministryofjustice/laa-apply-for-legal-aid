module Flow
  module Steps
    module Addresses
      HomeAddressManualsStep = Step.new(
        forward: lambda do |application|
          if Setting.linked_applications?
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
