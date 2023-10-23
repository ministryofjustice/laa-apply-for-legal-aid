module CopyCase
  class ClonerService
    attr_accessor :copy, :original

    def self.call(copy, original)
      new(copy, original).call
    end

    def initialize(copy, original)
      @copy = copy
      @original = original
    end

    def call
      clone_proceedings
    end

  private

    def clone_proceedings
      new_proceedings = original.proceedings.each_with_object([]) do |proceeding, memo|
        memo << proceeding.deep_clone(except: %i[legal_aid_application_id proceeding_case_id])
      end

      copy.proceedings = new_proceedings
      copy.save!
    end
  end
end
