# frozen_string_literal: true

module MojComponent
  module Helpers
    def moj_alert(**, &)
      render(MojComponent::AlertComponent.new(**), &)
    end

    def moj_header(**, &)
      render(MojComponent::HeaderComponent.new(**), &)
    end

    def moj_interruption_card(**, &)
      render(MojComponent::InterruptionCardComponent.new(**), &)
    end

    def moj_sub_navigation(**, &)
      render(MojComponent::SubNavigationComponent.new(**), &)
    end
  end
end
