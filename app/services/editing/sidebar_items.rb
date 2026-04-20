module Editing
  class SidebarItems
    SECTION_PATHS = {
      financial_assessment: %w[
        dwp-override
        check_client_details
        advise-of-passport-benefit
        received_benefit_confirmation
        has_evidence_of_benefit
        about_financial_means
        applicant_employed
        employed
        full_employment_details
        employment_incomes
        unexpected_employment_incomes
        substantive_application
        does-client-use-online-banking
        bank_statements
        receives_state_benefits
        state_benefits
        add_other_state_benefits
        remove_state_benefits
        regular_incomes
        cash_income
        student_finance
        regular_outgoings
        cash_outgoing
        housing_benefits
        has_dependants
        dependants
        has_other_dependants
        remove_dependants
        open_banking_guidance
        email_address
        about_the_financial_assessment
        client_completed_means
        identify_types_of_income
        income_summary
        identify_types_of_outgoing
        outgoings_summary
      ],

      capital_and_assets: %w[
        capital_introduction
        own_home
        property_details
        vehicle
        vehicle_details
        remove_vehicles
        add_other_vehicles
        applicant_bank_account
        offline_account
        savings_and_investment
        other_assets
        restrictions
        disregarded_payments
        capital_disregards/add_details
        payments_to_review
      ],

      merits: %w[
        merits_task_list
        involved_children
        has_other_involved_children
        opponent_individuals
        opponent_new_organisations
        opponent_existing_organisations
        client_denial_of_allegation
        client_offered_undertakings
        date_client_told_incident
        in_scope_of_laspo
        has_other_opponent
        opponent_type
        opponents_mental_capacity
        domestic_abuse_summary
        matter_opposed_reason
        nature_of_urgencies
        client_is_biological_parent
        client_has_parental_responsibility
        client_is_child_subject
        client_check_parental_answer
        statement_of_case
        statement_of_case_upload
        second_appeal
        original_case_judge_level
        appeal_court_type
        second_appeal_court_type
        court_order
        is_matter_opposed
        when_contact_was_made
        chances_of_success
        attempts_to_settle
        linked_children
        opponents_application
        prohibited_steps
        specific_issue
        changes_since_original
        assessment_of_client
        assessment_result
        uploaded_evidence_collection
      ],

      final: %w[
        confirm_client_declaration
      ],
    }.freeze

    PATH_TO_SECTION = SECTION_PATHS.flat_map { |section, paths|
      paths.map { |p| [p, section] }
    }.to_h.freeze

    def initialize(path, legal_aid_application)
      @path = path
      @legal_aid_application = legal_aid_application
    end

    def call
      section = PATH_TO_SECTION[path]
      return [] unless section

      sidebar_items_for_section(section)
    end

  private

    attr_reader :path, :legal_aid_application

    def sidebar_items_for_section(section)
      case section
      when :financial_assessment
        financial_assessment_sidebar_items
      when :capital_and_assets
        capital_and_assets_sidebar_items
      when :merits
        merits_sidebar_items
      when :final
        all_sidebar_items
      else
        []
      end
    end

    def financial_assessment_sidebar_items
      %i[client_details]
    end

    def capital_and_assets_sidebar_items
      legal_aid_application.non_passported? ? %i[client_details financial_assessment] : %i[client_details]
    end

    def merits_sidebar_items
      if legal_aid_application.non_passported?
        %i[client_details financial_assessment capital_and_assets]
      elsif legal_aid_application.passported?
        %i[client_details capital_and_assets]
      else
        %i[client_details]
      end
    end

    def all_sidebar_items
      merits_sidebar_items + [:merits]
    end
  end
end
