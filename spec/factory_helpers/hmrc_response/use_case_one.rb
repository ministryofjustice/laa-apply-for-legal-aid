module FactoryHelpers
  module HMRCResponse
    class UseCaseOne # rubocop:disable Metrics/ClassLength
      def initialize(correlation_id, options = {})
        @correlation_id = correlation_id
        @options = options
      end

      def firstname
        @firstname ||= (@options[:firstname] || Faker::Name.first_name).upcase
      end

      def lastname
        @lastname ||= (@options[:lastname] || Faker::Name.first_name).upcase
      end

      def nino
        @nino ||= @options[:nino] || fake_nino
      end

      def dob
        @dob ||= (@options[:dob] || fake_dob).strftime('%Y-%m-%d')
      end

      def status
        @status ||= @options[:status] || 'completed'
      end

      def pay_frequency
        @pay_frequency ||= @options[:pay_frequency] || 'W4'
      end

      def tax_year
        @tax_year ||= @options[:tax_year] || '21-22'
      end

      def last_pay_date
        @last_pay_date ||= @options[:last_pay_date] || Time.zone.yesterday
      end

      def response
        {
          'submission' => @correlation_id,
          'status' => status,
          'data' => data_array
        }
      end

      private

      def data_array
        [
          correlation_element,
          individual_element,
          paye_element,
          { 'income/sa/selfAssessment' => { 'registrations' => [], 'taxReturns' => [] } },
          { 'income/sa/pensions_and_state_benefits/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/source/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/employments/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/additional_information/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/partnerships/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/uk_properties/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/foreign/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/further_details/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/interests_and_dividends/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/other/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/summary/selfAssessment' => { 'taxReturns' => [] } },
          { 'income/sa/trusts/selfAssessment' => { 'taxReturns' => [] } },
          employments_element,
          { 'benefits_and_credits/working_tax_credit/applications' => [] },
          { 'benefits_and_credits/child_tax_credit/applications' => [] }
        ]
      end

      def correlation_element
        {
          'correlation_id' => @correlation_id,
          'use_case' => 'use_case_one'
        }
      end

      def individual_element
        {
          'individuals/matching/individual' => {
            'firstName' => firstname,
            'lastName' => lastname,
            'nino' => nino,
            'dateOfBirth' => dob
          }
        }
      end

      def paye_element
        income_array = case pay_frequency
                       when 'W4'
                         four_weekly_income_array
                       when 'M1'
                         monthly_income_array
                       else
                         raise "Unrecognised pay frequency #{pay_frequency}"
                       end
        {
          'income/paye/paye' => {
            'income' => income_array
          }
        }
      end

      def monthly_income_array
        dates = [last_pay_date, last_pay_date - 1.month, last_pay_date - 2.months]
        dates.map { |date| income_for_date(date) }
      end

      def four_weekly_income_array
        dates = [last_pay_date, last_pay_date - 4.weeks, last_pay_date - 8.weeks]
        dates.map { |date| income_for_date(date) }
      end

      def income_for_date(date)
        { 'taxYear' => tax_year,
          'payFrequency' => pay_frequency,
          'weekPayNumber' => week_number(date),
          'paymentDate' => date.strftime('%Y-%m-%d'),
          'paidHoursWorked' => 'E',
          'taxablePayToDate' => 26_401.68,
          'taxablePay' => 6_512.92,
          'totalTaxToDate' => 5_442.66,
          'taxDeductedOrRefunded' => 1_325.66,
          'grossEarningsForNics' => {
            'inPayPeriod1' => 6_512.92
          } }
      end

      def employments_element
        {
          'employments/paye/employments' => [
            {
              'startDate' => '2019-06-04',
              'endDate' => '2099-12-31'
            }
          ]
        }
      end

      def income_array
        tax_
      end

      def fake_nino
        "#{nino_alpha}#{nino_alpha}#{nino_numeric}#{nino_alpha}"
      end

      def nino_alpha
        %w[A B C E G H P R T W Z].sample
      end

      def nino_numeric
        rand(100_000..999_999)
      end

      def fake_dob
        Faker::Date.between(from: 70.years.ago, to: 16.years.ago)
      end

      # returns week number in tax year (sort of)
      def week_number(date)
        year_week_number = date.strftime('%U').to_i
        year_week_number > 14 ? year_week_number - 14 : year_week_number + 38
      end
    end
  end
end
