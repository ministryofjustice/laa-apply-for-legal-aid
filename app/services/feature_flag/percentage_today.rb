module FeatureFlag
  class PercentageToday
    def initialize(class_name, percent)
      @class = class_name.classify.constantize
      @percent = percent.to_int
      @created_today = @class.where(created_at: Time.zone.today..).count
    end

    def self.call(class_name, percent)
      new(class_name, percent).call
    end

    def call
      return false if @created_today.zero?

      # return true if a count of items returned today/percentage is valid
      # So if percent is 10% and there have been 9 already today then return true
      (@created_today % (100 / @percent)).zero?
    end
  end
end
