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
      clone_application_merits
    end

  private

    def clone_proceedings
      target.proceedings = source.proceedings.deep_dup
      target.save!
    end

    def clone_application_merits
      merits = %i[
        allegation
        domestic_abuse_summary
        latest_incident
        involved_children
        opponents
        parties_mental_capacity
        statement_of_case
        undertaking
        urgency
      ]

      merits.each do |merit|
        attribute = source.public_send(merit)

        next if attribute.nil?

        copy = attribute.deep_dup
        target.update!("#{merit}": copy)
      end
    end
  end
end
