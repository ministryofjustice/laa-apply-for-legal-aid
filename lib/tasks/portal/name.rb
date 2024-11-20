module Portal
  class Name
    attr_accessor :portal_name_valid, :errors

    def initialize(name)
      @name = name
      @result = {
        original_name:,
        display_name:,
        portal_username:,
        portal_name_valid: nil,
        errors: nil,
      }
    end

    def build
      @result
    end

    def original_name
      @original_name ||= parse_name
    end

    def portal_username
      @portal_username ||= parse_name.upcase.gsub(" ", "%20")
    end

    def display_name
      @display_name ||= parse_name.upcase
    end

  private

    def parse_name
      @name = strip_email if name_is_slack_email?
      @name
    end

    def name_is_slack_email?
      @name.include?("<MAILTO:")
    end

    def strip_email
      @name.match(/\|(.*)>/)[1]
    end
  end
end
