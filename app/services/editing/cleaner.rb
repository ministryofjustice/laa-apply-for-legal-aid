module Editing
  def self.sections
    {
      client_details: { state_machine_event: ->(_legal_aid_application) { :force_check_applicant_details! } },
      financial_assessment: { state_machine_event: ->(_legal_aid_application) { :force_check_means_income! } },
      capital_and_assets: { state_machine_event: ->(legal_aid_application) { legal_aid_application.passported? ? :force_check_passported_answers! : :force_check_non_passported_means! } },
      merits: { state_machine_event: ->(_legal_aid_application) { :force_provider_enter_merits! } },
    }
  end

  class Cleaner
    def initialize(legal_aid_application, reset_to_section)
      @legal_aid_application = legal_aid_application
      @reset_to_section = reset_to_section
      @clean_from_index = Editing.sections.keys.index(reset_to_section.to_sym) + 1
    end

    def call
      return unless valid_section?

      ActiveRecord::Base.transaction do
        legal_aid_application.state_machine.send(state_machine_event)

        sections_to_clean.each do |section|
          send("clean_#{section}")
        end
      end
    end

  private

    attr_reader :legal_aid_application, :reset_to_section, :clean_from_index

    def valid_section?
      Editing.sections.key?(reset_to_section.to_sym)
    end

    def state_machine_event
      Editing.sections[reset_to_section.to_sym][:state_machine_event].call(legal_aid_application)
    end

    # NOTE: if we're returning to client details we also need to delete the DWP data as that is derived from the client details and will need requerying
    def sections_to_clean
      @sections_to_clean ||= Editing.sections.keys[@clean_from_index..] || []
      @sections_to_clean.unshift(:dwp_data) if @reset_to_section.to_sym == :client_details
      @sections_to_clean
    end

    # TODO: ticket for writing this cleaner
    def clean_dwp_data
      DWPDataCleaner.new(legal_aid_application).call
    end

    # TODO: ticket for writing this cleaner
    def clean_financial_assessment
      FinancialAssessmentCleaner.new(legal_aid_application).call
    end

    # TODO: ticket for writing this cleaner
    def clean_capital_and_assets
      CapitalAndAssetsCleaner.new(legal_aid_application).call
    end

    # TODO: ticket for writing this cleaner
    def clean_merits
      MeritsCleaner.new(legal_aid_application).call
    end
  end
end
