module CopyCase
  class ClonerService
    class ClonerServiceError < StandardError; end

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
      clone_opponents
    rescue ClonerServiceError => e
      AlertManager.capture_exception(e)
      Rails.logger.error(e.message)
      false
    end

  private

    def clone_proceedings
      new_proceedings = []
      source.proceedings.each do |source_proceeding|
        dup_proceeding = source_proceeding.dup
        dup_proceeding.legal_aid_application_id = nil
        dup_proceeding.proceeding_case_id = nil

        dup_proceeding.attempts_to_settle = source_proceeding.attempts_to_settle.dup
        dup_proceeding.chances_of_success = source_proceeding.chances_of_success.dup
        dup_proceeding.opponents_application = source_proceeding.opponents_application.dup
        dup_proceeding.prohibited_steps = source_proceeding.prohibited_steps.dup
        dup_proceeding.specific_issue = source_proceeding.specific_issue.dup
        dup_proceeding.vary_order = source_proceeding.vary_order.dup

        source_proceeding.scope_limitations.each do |limitation|
          dup_limitation = limitation.dup
          dup_limitation.proceeding_id = nil
          dup_proceeding.scope_limitations << dup_limitation
        end

        new_proceedings << dup_proceeding
      end

      target.proceedings = new_proceedings
      target.save!
    rescue StandardError => e
      raise ClonerServiceError, "clone_proceedings error: #{e.message}"
    end

    def clone_application_merits
      merits = %i[
        allegation
        domestic_abuse_summary
        emergency_cost_override
        emergency_cost_reasons
        emergency_cost_requested
        latest_incident
        in_scope_of_laspo
        matter_opposition
        parties_mental_capacity
        statement_of_case
        undertaking
        urgency
      ]

      merits.each do |merit|
        attribute = source.public_send(merit)

        next if attribute.nil?

        copy = attribute.dup
        target.update!("#{merit}": copy)
      end
    rescue StandardError => e
      raise ClonerServiceError, "clone_application_merits error: #{e.message}"
    end

    def clone_opponents
      source.opponents.each do |opponent|
        dup_opposable = opponent.opposable.dup
        dup_opposable.save!
        dup_opponent = opponent.dup
        dup_opponent.opposable_id = dup_opposable.id
        dup_opponent.legal_aid_application_id = target.id
        target.opponents << dup_opponent
      end

      target.save!
    rescue StandardError => e
      raise ClonerServiceError, "clone_opponents error: #{e.message}"
    end
  end
end
