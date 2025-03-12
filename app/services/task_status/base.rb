module TaskStatus
  class Base
    attr_accessor :application

    def initialize(application)
      @application = application
    end
  end
end
