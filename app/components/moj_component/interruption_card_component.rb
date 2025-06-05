module MojComponent
  class InterruptionCardComponent < ViewComponent::Base
    attr_reader :heading

    renders_one :body
    renders_one :actions

    def initialize(heading:)
      super
      @heading = heading
    end
  end
end
