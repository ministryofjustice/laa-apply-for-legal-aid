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
      # ------------------------------------------------------------------------------------------------
      # attempt 1 - using deep cloneable, not maintained, unhelpful error
      # failed rspec ./spec/services/copy_case/cloner_service_spec.rb:152
      # Error: Failed to replace proceedings because one or more of the new records could not be saved.
      # new_proceedings = source.proceedings.each_with_object([]) do |proceeding, memo|
      #   memo << proceeding.deep_clone(
      #     except: %i[legal_aid_application_id proceeding_case_id],
      #     include: %i[
      #       scope_limitations
      #       attempts_to_settle
      #       chances_of_success
      #       opponents_application
      #       proceeding_linked_children
      #       prohibited_steps
      #       specific_issue
      #       vary_order
      #     ],
      #   )
      # end
      # target.proceedings = new_proceedings
      # target.save!

      # ------------------------------------------------------------------------------------------------
      # attempt 2 - deep dup
      # copies rather than duplicates
      # target.proceedings = source.proceedings.deep_dup
      # target.save!

      # ------------------------------------------------------------------------------------------------
      # attempt 3 - marshall
      # new_proceedings = Marshal.load(Marshal.dump(source.proceedings))
      # target.proceedings = new_proceedings
      # target.save!

      # ------------------------------------------------------------------------------------------------
      # attempt 4 - very manual

      new_proceedings = []
      source.proceedings.each do |source_proceeding|
        dup_proceeding = source_proceeding.deep_dup
        dup_proceeding.legal_aid_application_id = nil
        dup_proceeding.proceeding_case_id = nil

        dup_proceeding.attempts_to_settle = source_proceeding.attempts_to_settle.deep_dup
        dup_proceeding.chances_of_success = source_proceeding.chances_of_success.deep_dup
        dup_proceeding.opponents_application = source_proceeding.opponents_application.deep_dup
        dup_proceeding.prohibited_steps = source_proceeding.prohibited_steps.deep_dup
        dup_proceeding.specific_issue = source_proceeding.specific_issue.deep_dup
        dup_proceeding.vary_order = source_proceeding.vary_order.deep_dup

        dup_proceeding.scope_limitations << source_proceeding.scope_limitations.deep_dup

        source_proceeding.involved_children.each do |child|
          dup_child = child.deep_dup
          dup_child.legal_aid_application_id = target.id
          dup_proceeding.involved_children << dup_child
        end

        # new_ic = []
        # source_proceeding.involved_children.each do |ic|
        #   binding.pry
        #   dup_ic = ic.deep_dup
        #   dup_ic.proceeding_id = nil
        #   new_ic << dup_ic
        # end
        # dup_proceeding.involved_children << new_ic

        new_proceedings << dup_proceeding
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

        copy = attribute.deep_dup
        target.update!("#{merit}": copy)
      end
    end
  end
end
