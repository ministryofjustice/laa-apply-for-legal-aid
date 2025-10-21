module MojComponent
  class InterruptionCardComponent < ApplicationComponent
    attr_reader :heading

    renders_one :body
    renders_one :actions

    def initialize(heading:)
      @heading = heading
      super()
    end
  end
end
