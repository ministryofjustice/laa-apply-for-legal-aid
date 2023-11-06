module CopyCase
  class ClonerService
    attr_accessor :target, :source

    def self.call(target, source)
      new(target, source).call
    end

    def initialize(target, source)
      @target = target
      @source = source
    end

    def call
      clone_proceedings

      # TODO: clone opponents, clone other merits tasks(??)
      # and copy values from other fields on legal_aid_application source object
      # see ticket AP-4577
    end

  private

    def clone_proceedings
      new_proceedings = source.proceedings.each_with_object([]) do |proceeding, memo|
        memo << proceeding.deep_clone(
          except: %i[legal_aid_application_id proceeding_case_id],
          include: [:scope_limitations],
        )
      end

      target.proceedings = new_proceedings
      target.save!
    end
  end
end
