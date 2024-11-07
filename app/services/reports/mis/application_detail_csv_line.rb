module Reports
  module MIS
    class ApplicationDetailCsvLine
      include Sanitisable

      attr_reader :laa

      delegate :applicant,
               :applicant_receives_benefit?,
               :cash_transactions,
               :ccms_reason,
               :ccms_submission,
               :cfe_result,
               :created_at,
               :dependants,
               :dwp_override,
               :emergency_cost_override?,
               :emergency_cost_requested,
               :gateway_evidence,
               :involved_children,
               :lead_proceeding,
               :office,
               :other_assets_declaration,
               :outstanding_mortgage_amount,
               :own_home,
               :percentage_home,
               :proceedings,
               :property_value,
               :provider,
               :parties_mental_capacity,
               :domestic_abuse_summary,
               :savings_amount,
               :merits_submitted_at,
               :policy_disregards,
               :shared_ownership,
               :state,
               :statement_of_case_uploaded?,
               :used_delegated_functions?,
               :used_delegated_functions_on,
               :used_delegated_functions_reported_on,
               :lowest_prospect_of_success,
               :hmrc_responses,
               :vehicles, to: :laa

      delegate :case_ccms_reference, to: :ccms_submission

      delegate :offline_current_accounts,
               :offline_savings_accounts,
               :cash,
               :other_person_account,
               :national_savings,
               :peps_unit_trusts_capital_bonds_gov_stocks,
               :plc_shares,
               :life_assurance_endowment_policy, to: :savings_amount

      delegate :valuable_items_value,
               :second_home_value,
               :timeshare_property_value,
               :land_value,
               :inherited_assets_value,
               :money_owed_value, to: :other_assets_declaration

      delegate :firm,
               :username, to: :provider

      def self.header_row
        [
          "Firm name",
          "User name",
          "Office ID",
          "Applicant name",
          "Applicant age",
          "Non means tested?",
          "State",
          "CCMS reason",
          "CCMS reference number",
          "Single/Multi Proceedings",
          "Matter types",
          "No. of proceedings",
          "Proceeding types selected",
          "LASPO Question",
          "Case Type",
          "DWP Overridden",
          "Delegated functions used",
          "Proceedings DF used",
          "Proceedings DF not used",
          "Delegated functions dates",
          "Delegated functions reported",
          "Requested higher limit?",
          "Limit requested",
          "Payments received in cash?",
          "Student finance received?",
          "Payments made in cash?",
          "Client has dependants?",
          "Disregarded income/capital?",
          "Own home?",
          "Value",
          "Outstanding mortgage",
          "Shared?",
          "%age owned",
          "Vehicle?",
          "Vehicle 1 value",
          "Vehicle 1 Outstanding loan?",
          "Vehicle 1 Loan remaining",
          "Vehicle 1 Date purchased",
          "Vehicle 1 In Regular use?",
          "Current acct?",
          "Savings acct?",
          "Cash?",
          "Third party acct?",
          "NSI and PB?",
          "PLC shares?",
          "Govt. stocks, bonds?, etc?",
          "Life assurance?",
          "Current acct value",
          "Savings acct value",
          "Cash value",
          "Third party acct value",
          "NSI and PB value",
          "PLC shares value",
          "Govt. stocks, bonds value",
          "Life assurance value",
          "Valuable items?",
          "Second home?",
          "Timeshare?",
          "Land?",
          "Inheritance?",
          "Money owed?",
          "Valuable items value",
          "Second home value",
          "Timeshare value",
          "Land value",
          "Inheritance value",
          "Money owed value",
          "Restrictions?",
          "Restriction details",
          "Fully eligible (means)?",
          "Partially eligible (means)?",
          "Number of children involved",
          "Supporting evidence uploaded?",
          "Number of items of evidence",
          "Parties can understand?",
          "Ability to understand details",
          "Warning letter sent?",
          "Warning letter details",
          "Police notified?",
          "Police notification details",
          "Bail conditions set?",
          "Bail details",
          "Prospects of success",
          "Prospects of success details",
          "SOC uploaded?",
          "Application started",
          "Application submitted",
          "Application deleted",
          "HMRC data",
          "Employment Status",
          "HMRC call successful",
          "Free text required",
          "Free text optional",
          "Multi Employment",
          "Bank statements path",
          "Truelayer path",
          "Truelayer data",
          "Has partner?",
          "Contrary interest?",
          "Partner DWP challenge?",
          "Family linked?",
          "Family link lead?",
          "Number of family links",
          "Legal Linked?",
          "Legal link lead?",
          "Number of legal links",
          "No fixed address",
          "Previous CCMS ref?",
          "Child subject client involvment type?",
          "Biological parent relationship?",
          "Parental responsibility order relationship?",
          "Child subject relationship?",
          "Autogranted?",
        ]
      end

      def self.call(legal_aid_application)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        @laa = legal_aid_application
        @line = []
      end

      def call
        provider_firm_details
        application_details
        proceeding_details
        passported_check_result
        dwp_overridden
        delegated_functions
        default_cost_overrride
        income_details
        main_home_details
        vehicle_details
        savings_and_investment_details
        other_assets_details
        restrictions
        eligibility
        parties_mental_capacity_attrs
        domestic_abuse_summary_attrs
        merits
        hmrc_data
        banking_data
        partner
        linked_applications
        home_address
        previous_ccms_ref
        child_client_involvement_type
        sca
        autogranted
        sanitise
      end

    private

      def applicant_age
        applicant.age
      rescue NoMethodError
        nil
      end

      def chances_of_success
        return lead_proceeding&.chances_of_success unless lead_proceeding.nil?

        proceedings.first&.chances_of_success
      end

      def provider_firm_details
        @line << firm.name
        @line << username
        @line << office&.code
      end

      def application_details
        @line << applicant.full_name
        @line << applicant_age
        @line << yesno(laa.non_means_tested?)
        @line << state
        @line << ccms_reason
        @line << (ccms_submission.nil? ? "" : case_ccms_reference)
        @line << (proceedings.count > 1 ? "Multi" : "Single")
      end

      def proceeding_details
        @line << proceedings.map(&:matter_type).uniq.sort.join(", ")
        @line << proceedings.count
        @line << proceedings.map(&:meaning).sort.join(", ")
        @line << laspo_question
      end

      def income_details
        @line << yesno(cash_transactions.credits.any?)
        @line << yesno(applicant.student_finance)
        @line << yesno(cash_transactions.debits.any?)
        @line << yesno(dependants.any?)
        @line << yesno(policy_disregards.present?)
      end

      def passported_check_result
        @line << (applicant_receives_benefit? ? "Passported" : "Non-Passported")
      end

      def dwp_overridden
        @line << yesno(dwp_override)
      end

      def delegated_functions
        @line << yesno(used_delegated_functions?)
        @line << proceedings_df_used
        @line << proceedings_df_not_used
        @line << proceedings.map(&:pretty_df_date).join(", ")
        @line << (used_delegated_functions? ? used_delegated_functions_reported_on&.strftime("%Y-%m-%d") : "")
      end

      def default_cost_overrride
        @line << yesno(emergency_cost_override?)
        @line << emergency_cost_requested
      end

      def main_home_details
        @line << own_home
        @line << (own_home == "no" ? "" : property_value)
        @line << (own_home == "mortgage" ? outstanding_mortgage_amount : "")
        @line << shared_ownership
        @line << (shared_ownership == "no_sole_owner" ? "" : percentage_home)
      end

      def vehicle_details
        @line << (vehicles.any? ? vehicles.count : "No")
        vehicles.any? ? vehicle_attrs : @line += ["", "", "", "", ""]
      end

      def vehicle_attrs
        @line << vehicles.first.estimated_value
        @line << (nil_or_zero?(vehicles.first.payment_remaining) ? "No" : "Yes")
        @line << (nil_or_zero?(vehicles.first.payment_remaining) ? "" : vehicles.first.payment_remaining)
        @line << vehicles.first.purchased_on&.strftime("%Y-%m-%d")
        @line << yesno(vehicles.first.used_regularly?)
      end

      def savings_and_investment_details
        if savings_amount.present?
          sandi_bools
          sandi_values
        else
          8.times { @line << "No" }
          8.times { @line << "" }
        end
      end

      def sandi_attributes
        [
          offline_current_accounts,
          offline_savings_accounts,
          cash,
          other_person_account,
          national_savings,
          plc_shares,
          peps_unit_trusts_capital_bonds_gov_stocks,
          life_assurance_endowment_policy,
        ]
      end

      def sandi_bools
        sandi_attributes.each { |attr| @line << yesno(attr.present?) }
      end

      def sandi_values
        sandi_attributes.each { |attr| @line << (attr.nil? ? "" : attr) }
      end

      def other_assets_details
        if other_assets_declaration.present?
          other_assets_bools
          other_assets_values
        else
          6.times { @line << "No" }
          6.times { @line << "" }
        end
      end

      def other_assets_attributes
        [
          valuable_items_value,
          second_home_value,
          timeshare_property_value,
          land_value,
          inherited_assets_value,
          money_owed_value,
        ]
      end

      def other_assets_bools
        other_assets_attributes.each { |attr| @line << yesno(attr.present?) }
      end

      def other_assets_values
        other_assets_attributes.each do |attr|
          @line << (attr.nil? ? "" : attr)
        end
      end

      def restrictions
        @line << yesno(laa.has_restrictions?)
        @line << (laa.has_restrictions? ? laa.restrictions_details : "")
      end

      def eligibility
        @line << yesno(cfe_result&.eligible?)
        @line << yesno(cfe_result&.partially_eligible?)
        @line << involved_children.count
        @line << yesno(gateway_evidence.present?)
        @line << gateway_evidence_count
      end

      def parties_mental_capacity_attrs
        return 2.times { @line << "" } if laa.parties_mental_capacity.nil? || laa.parties_mental_capacity.blank?

        @line << yesno(laa&.parties_mental_capacity&.understands_terms_of_court_order?)
        @line << laa&.parties_mental_capacity&.understands_terms_of_court_order_details
      end

      def domestic_abuse_summary_attrs
        return 6.times { @line << "" } if laa.domestic_abuse_summary.nil? || laa.domestic_abuse_summary.blank?

        @line << yesno(laa&.domestic_abuse_summary&.warning_letter_sent?)
        @line << laa&.domestic_abuse_summary&.warning_letter_sent_details
        @line << yesno(laa&.domestic_abuse_summary&.police_notified?)
        @line << laa&.domestic_abuse_summary&.police_notified_details
        @line << yesno(laa&.domestic_abuse_summary&.bail_conditions_set?)
        @line << laa&.domestic_abuse_summary&.bail_conditions_set_details
      end

      def merits
        @line << lowest_prospect_of_success
        @line << chances_of_success&.success_prospect_details
        @line << statement_of_case_uploaded?
        @line << created_at.strftime("%Y-%m-%d")
        @line << merits_submitted_at&.strftime("%Y-%m-%d")
        @line << yesno(laa.discarded?)
      end

      def hmrc_data
        @line << yesno(HMRC::Response.where(legal_aid_application_id: laa.id).present?)
        @line << (laa.applicant.not_employed? ? "None" : employment_concatenation) # "Employment Status"
        @line << yesno(laa.hmrc_employment_income? && !laa.has_multiple_employments?) # "HMRC call successful",
        @line << yesno(laa.full_employment_details.present?) # "Free text required",
        @line << yesno(laa.applicant.extra_employment_information_details.present?) # "Free text optional",
        @line << yesno(laa.has_multiple_employments?) # "Multi Employment",
      end

      def banking_data
        @line << yesno(laa.bank_statement_upload_path?) # "Bank statements path",
        @line << yesno(laa.truelayer_path?) # "Truelayer path",
        @line << yesno(laa.bank_transactions.any?) # Truelayer data""
      end

      def partner
        @line << yesno(laa.applicant_has_partner?)
        if laa.applicant_has_partner?
          @line << yesno(!laa.applicant_has_partner_with_no_contrary_interest? || nil)
          @line << yesno(laa&.partner&.shared_benefit_with_applicant? || laa&.applicant&.shared_benefit_with_partner? || nil)
        else
          @line << nil
          @line << nil
        end
      end

      def linked_applications
        @line << yesno(laa.family_linked?)
        if laa.family_linked?
          @line << laa.family_linked_lead_or_associated
          @line << laa.family_linked_applications_count
        else
          @line << nil
          @line << nil
        end
        @line << yesno(laa.legal_linked?)
        if laa.legal_linked?
          @line << laa.legal_linked_lead_or_associated
          @line << laa.legal_linked_applications_count
        else
          @line << nil
          @line << nil
        end
      end

      def home_address
        @line << yesno(laa.applicant.no_fixed_residence?)
      end

      def previous_ccms_ref
        @line << yesno(laa.applicant.previous_reference.present?)
      end

      def child_client_involvement_type
        @line << yesno(proceedings.any? { |proceeding| proceeding.client_involvement_type_ccms_code.eql?("W") })
      end

      def sca
        if laa.special_children_act_proceedings?
          @line << yesno(laa.biological_parent?)
          @line << yesno(laa.parental_responsibility_order?)
          @line << yesno(laa.child_subject?)
        else
          @line << nil
          @line << nil
          @line << nil
        end
      end

      def autogranted
        @line << yesno(laa.auto_grant_special_children_act?(nil))
      end

      def yesno(value)
        value == true ? "Yes" : "No"
      end

      def nil_or_zero?(value)
        value.nil? || value.zero?
      end

      def laspo_question
        case @laa.in_scope_of_laspo
        when true
          "Yes"
        when false
          "No"
        else
          ""
        end
      end

      def employment_concatenation
        [
          convert_employment_type_to_string("employed"),
          convert_employment_type_to_string("self_employed"),
          convert_employment_type_to_string("armed_forces"),
        ].compact.join(", ")
      end

      def convert_employment_type_to_string(value)
        value.humanize if laa.applicant.send(:"#{value}?")
      end

      def gateway_evidence_count
        gateway_evidence.present? ? laa.attachments.gateway_evidence_pdf.count : ""
      end

      def proceedings_df_used
        proceedings.using_delegated_functions.map(&:meaning).join(", ")
      end

      def proceedings_df_not_used
        proceedings.not_using_delegated_functions.map(&:meaning).join(", ")
      end
    end
  end
end
