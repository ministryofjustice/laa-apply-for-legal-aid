module Portal
  class GenerateScript
    def initialize(name_array)
      @names = name_array
    end

    def self.call(names)
      new(names).call
    end

    def call
      header + names
    end

  private

    def names
      result = @names.map do |name|
        name_line(name.display_name)
      end
      result.join("\n")
    end

    def name_line(name)
      "uniquemember: cn=#{name},cn=users,dc=lab,dc=gov"
    end

    def header
      <<~HEADER
        dn: cn=CCMS_Apply,cn=Groups,dc=lab,dc=gov
        changetype: modify
        add: uniquemember
      HEADER
    end
  end
end
