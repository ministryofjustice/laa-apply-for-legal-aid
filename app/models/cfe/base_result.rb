module CFE
  class BaseResult < ApplicationRecord # rubocop:disable Metrics/ClassLength
    belongs_to :legal_aid_application
    belongs_to :submission

    self.table_name = 'cfe_results'

    def result_hash
      JSON.parse(result, symbolize_names: true)
    end

    def overview
      if capital_contribution_required? && !legal_aid_application.has_restrictions?
        'contribution_required'
      elsif capital_contribution_required? && legal_aid_application.has_restrictions?
        'manual_check_required'
      else
        assessment_result
      end
    end

    def capital_contribution_required?
      assessment_result == 'contribution_required'
    end

    alias contribution_required? capital_contribution_required?

    def eligible?
      assessment_result == 'eligible'
    end

    def main_home
      property[:main_home]
    end

    ################################################################
    #                                                              #
    #  MAIN HOME VALUES                                            #
    #                                                              #
    ################################################################

    def main_home_value
      main_home[:value].to_d
    end

    def main_home_outstanding_mortgage
      main_home[:allowable_outstanding_mortgage].to_d * -1
    end

    def main_home_transaction_allowance
      main_home[:transaction_allowance].to_d * -1
    end

    def main_home_equity_disregard
      main_home[:main_home_equity_disregard].to_d * -1
    end

    def main_home_assessed_equity
      main_home[:assessed_equity].to_d.positive? ? main_home[:assessed_equity].to_d : 0.0
    end

    ################################################################
    #                                                              #
    #  ADDITIONAL PROPERTY                                         #
    #                                                              #
    ################################################################

    def additional_property?
      existing_and_not_all_zero?(property[:additional_properties].first)
    end

    def additional_property
      property[:additional_properties].first
    end

    def additional_property_value
      additional_property[:value].to_d
    end

    def additional_property_transaction_allowance
      additional_property[:transaction_allowance].to_d * -1
    end

    def additional_property_mortgage
      additional_property[:allowable_outstanding_mortgage].to_d * -1
    end

    def additional_property_assessed_equity
      additional_property[:assessed_equity].to_d.positive? ? additional_property[:assessed_equity].to_d : 0.0
    end

    ################################################################
    #                                                              #
    #  CAPITAL ITEMS                                               #
    #                                                              #
    ################################################################

    def total_savings
      capital[:total_liquid].to_d
    end

    def total_other_assets
      capital[:total_non_liquid].to_d
    end

    ################################################################
    #                                                              #
    #  VEHICLE                                                     #
    #                                                              #
    ################################################################

    def vehicle_loan_amount_outstanding
      vehicle[:loan_amount_outstanding].to_d
    end

    def vehicle_disregard
      vehicle_value - vehicle_assessed_amount
    end

    def vehicle_assessed_amount
      vehicle[:assessed_value].to_d
    end

    ################################################################
    #                                                              #
    #  TOTALS                                                      #
    #                                                              #
    ################################################################

    def pensioner_capital_disregard
      capital[:pensioner_capital_disregard].to_d * -1
    end

    def total_capital_before_pensioner_disregard
      total_property + total_savings + total_vehicles + total_other_assets
    end

    def total_disposable_capital
      [0, (total_capital_before_pensioner_disregard + pensioner_capital_disregard)].max
    end

    ################################################################
    #                                                              #
    #  UTILITY METHODS                                             #
    #                                                              #
    ################################################################

    def existing_and_not_all_zero?(property)
      property.present? && property[:value].to_d > 0.0
    end
  end
end
