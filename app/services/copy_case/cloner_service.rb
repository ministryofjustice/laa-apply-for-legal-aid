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
      new_proceedings = source.proceedings.each_with_object([]) do |proceeding, memo|
        memo << proceeding.deep_clone(
          except: %i[legal_aid_application_id proceeding_case_id],
          include: %i[
            scope_limitations
            attempts_to_settle
            chances_of_success
            opponents_application
            proceeding_linked_children
            prohibited_steps
            specific_issue
            vary_order
          ],
        )
      end

      target.proceedings = new_proceedings
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
