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
      clone_merits
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

    def clone_merits
      application_merits = %i[
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

      application_merits.each do |merit|
        attribute = source.public_send(merit)

        next if attribute.nil?

        copy = case merit
               when :opponents
                 attribute.each_with_object([]) do |item, memo|
                   memo << item.deep_clone(include: [:opposable])
                 end
               when :involved_children
                 attribute.each_with_object([]) do |item, memo|
                   memo << item.deep_clone
                 end
               else
                 attribute.deep_clone
               end

        target.update!("#{merit}": copy)
      end
    end
  end
end
