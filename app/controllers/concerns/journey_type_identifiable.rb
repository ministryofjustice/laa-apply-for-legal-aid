module JourneyTypeIdentifiable
  extend ActiveSupport::Concern

  included do
    helper_method :journey_type

    def journey_type
      @journey_type ||= first_module_of_parent_name_space.to_sym
    end

    def first_module_of_parent_name_space
      parent_name_space_module.to_s.snakecase.split('/').first
    end

    def parent_name_space_module
      self.class.module_parent
    end
  end
end
