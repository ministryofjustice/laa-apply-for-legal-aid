module FactoryHelpers
  module HMRCResponse
    class UseCaseOne
      def initialize(correlation_id, options = {})
        @correlation_id = correlation_id
        @options = options
        generate_named_data if @options.key?(:named_data)
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
          'data' => @options[:data_array] || default_data_array
        }
      end

    private

      def generate_named_data
        case @options[:named_data]
        when :example1_usecase1
          example1_usecase1
        when :multiple_employments_usecase1
          example1_usecase1
          @options[:data_array][16]['employments/paye/employments'] << { 'startDate' => '2021-09-25', 'endDate' => '2099-12-31' }
        else
          raise "named data #{@options[:named_data]} passed to #{self.class}} unrecognised"
        end
      end

      def example1_usecase1
        @options = {
          first_name: 'John',
          last_name: 'Doe',
          data_array: [
            {
              correlation_id: @correlation_id,
              use_case: 'use_case_one'
            },
            {
              'individuals/matching/individual' => {
                firstName: firstname,
                lastName: lastname,
                nino: nino,
                dateOfBirth: '1994-04-30'
              }
            },
            {
              'income/paye/paye' => {
                income: [
                  {
                    taxYear: '21-22',
                    payFrequency: 'M1',
                    monthPayNumber: 8,
                    paymentDate: '2021-11-28',
                    paidHoursWorked: 'D',
                    taxablePayToDate: 17_014.34,
                    taxablePay: 1868.98,
                    totalTaxToDate: 1706.8,
                    taxDeductedOrRefunded: 161.8,
                    employeePensionContribs: {
                      paidYTD: 0,
                      notPaidYTD: 514.17,
                      paid: 0,
                      notPaid: 53.96
                    },
                    grossEarningsForNics: { inPayPeriod1: 1868.98 },
                    totalEmployerNics: { inPayPeriod1: 156.21, ytd: 1534.31 },
                    employeeNics: { inPayPeriod1: 128.64, ytd1: 1276.59 }
                  },
                  {
                    taxYear: '21-22',
                    payFrequency: 'M1',
                    monthPayNumber: 7,
                    paymentDate: '2021-10-28',
                    paidHoursWorked: 'D',
                    taxablePayToDate: 15_145.36,
                    taxablePay: 1615.78,
                    totalTaxToDate: 1545,
                    taxDeductedOrRefunded: 111,
                    employeePensionContribs: {
                      paidYTD: 0,
                      notPaidYTD: 460.21,
                      paid: 0,
                      notPaid: 43.83
                    },
                    grossEarningsForNics: { inPayPeriod1: 1868.98 },
                    totalEmployerNics: { inPayPeriod1: 156.21, ytd: 1534.31 },
                    employeeNics: { inPayPeriod1: 128.64, ytd1: 1276.59 }
                  },
                  {
                    taxYear: '21-22',
                    payFrequency: 'M1',
                    monthPayNumber: 6,
                    paymentDate: '2021-09-28',
                    paidHoursWorked: 'D',
                    taxablePayToDate: 13_529.58,
                    taxablePay: 2492.61,
                    totalTaxToDate: 1434,
                    taxDeductedOrRefunded: 286.6,
                    employeePensionContribs: {
                      paidYTD: 0,
                      notPaidYTD: 416.38,
                      paid: 0,
                      notPaid: 78.9
                    },
                    grossEarningsForNics: { inPayPeriod1: 2492.61 },
                    totalEmployerNics: { inPayPeriod1: 242.27, ytd: 1256.83 },
                    employeeNics: { inPayPeriod1: 203.47, ytd1: 1049.7 }
                  },
                  {
                    taxYear: '21-22',
                    payFrequency: 'M1',
                    monthPayNumber: 5,
                    paymentDate: '2021-08-28',
                    paidHoursWorked: 'D',
                    taxablePayToDate: 11_036.97,
                    taxablePay: 2345.29,
                    totalTaxToDate: 1147.4,
                    taxDeductedOrRefunded: 257.2,
                    employeePensionContribs: {
                      paidYTD: 0,
                      notPaidYTD: 337.48,
                      paid: 0,
                      notPaid: 73.01
                    },
                    grossEarningsForNics: { inPayPeriod1: 2345.29 },
                    totalEmployerNics: { inPayPeriod1: 221.94, ytd: 1014.56 },
                    employeeNics: { inPayPeriod1: 185.79, ytd1: 846.23 }
                  }
                ]
              }
            },
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
            { 'employments/paye/employments' => [{ startDate: '2013-04-22', endDate: '2099-12-31' }] },
            { 'benefits_and_credits/working_tax_credit/applications' => [{ awards: [] }] },
            { 'benefits_and_credits/child_tax_credit/applications' => [{ awards: [] }] }
          ]
        }
      end

      def default_data_array
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
