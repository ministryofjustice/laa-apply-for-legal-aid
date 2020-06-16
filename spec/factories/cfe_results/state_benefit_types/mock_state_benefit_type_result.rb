module CFE
  class MockStateBenefitTypeResult # rubocop:disable Metrics/ClassLength
    def self.full_list
      [
        {
          'label' => 'age_related_payment',
          'name' => 'Age Related Payment',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'ARP',
          'category' => nil
        },
        {
          'label' => 'bereavement_allowance',
          'name' => 'Bereavement Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'BA',
          'category' => nil
        },
        {
          'label' => 'bereavement_payment',
          'name' => 'Bereavement Payment',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'BPT',
          'category' => nil
        },
        {
          'label' => 'child_maintenance',
          'name' => 'Child Maintenance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CM',
          'category' => nil
        },
        {
          'label' => 'christmas_bonus',
          'name' => 'Christmas Bonus',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'XB',
          'category' => nil
        },
        {
          'label' => 'cold_weather_payment',
          'name' => 'Cold Weather Payment',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CWP',
          'category' => nil
        },
        {
          'label' => 'incapacity_benefit',
          'name' => 'Incapacity Benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'IB',
          'category' => nil
        },
        {
          'label' => 'income_support',
          'name' => 'Income Support',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'IS',
          'category' => nil
        },
        {
          'label' => 'industrial_injuries_benefit',
          'name' => 'Industrial Injuries Benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'IIB',
          'category' => nil
        },
        {
          'label' => 'industrial_injuries_disablement_benefit',
          'name' => 'Industrial Injuries Disablement Benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'IIDB',
          'category' => nil
        },
        {
          'label' => 'jobseekers_allowance',
          'name' => 'Jobseeker’s Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'JSA',
          'category' => nil
        },
        {
          'label' => 'maternity_allowance',
          'name' => 'Maternity Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'MA',
          'category' => nil
        },
        {
          'label' => 'minimum_income_guarantee',
          'name' => 'Minimum Income Guarantee',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'MIG',
          'category' => nil
        },
        {
          'label' => 'mortgage_interest_direct',
          'name' => 'Mortgage Interest Direct',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'MID',
          'category' => nil
        },
        {
          'label' => 'pension_credit',
          'name' => 'Pension Credit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'PC',
          'category' => nil
        },
        {
          'label' => 'reduced_earnings_allowance',
          'name' => 'Reduced Earnings Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'REA',
          'category' => nil
        },
        {
          'label' => 'severe_disablement_allowance',
          'name' => 'Severe Disablement Allowance',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'SDA',
          'category' => nil
        },
        {
          'label' => 'state_pension',
          'name' => 'State Pension',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'SP',
          'category' => nil
        },
        {
          'label' => 'training_payment',
          'name' => 'Training Payment',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'T/P',
          'category' => nil
        },
        {
          'label' => 'universal_credit',
          'name' => 'Universal Credit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'UC',
          'category' => nil
        },
        {
          'label' => 'widows_benefit',
          'name' => 'Widow’s Benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'WB',
          'category' => nil
        },
        {
          'label' => 'widowed_mothers_allowance',
          'name' => 'Widowed Mother’s Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'WMA',
          'category' => nil
        },
        {
          'label' => 'widowed_parents_allowance',
          'name' => 'Widowed Parent’s Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'WPA',
          'category' => nil
        },
        {
          'label' => 'winter_fuel_payment',
          'name' => 'Winter Fuel Payment',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'WFP',
          'category' => nil
        },
        {
          'label' => 'other',
          'name' => 'Other state benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => nil,
          'category' => nil
        },
        {
          'label' => 'all_work_related_reqs',
          'name' => 'All Work Related Requirements',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'AWRR',
          'category' => nil
        },
        {
          'label' => 'child_benefit',
          'name' => 'Child Benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CHB',
          'category' => nil
        },
        {
          'label' => 'child_maintenance_deduction',
          'name' => 'Child Maintenance Deduction',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CMD',
          'category' => nil
        },
        {
          'label' => 'cont_to_maintenance',
          'name' => 'Contribution to Maintenance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CTM',
          'category' => nil
        },
        {
          'label' => 'direct_credit_transfer',
          'name' => 'Direct Credit Transfer',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'DCT',
          'category' => nil
        },
        {
          'label' => 'enhanced_disability_premium',
          'name' => 'Enhanced Disability Premium',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'EDP',
          'category' => nil
        },
        {
          'label' => 'financial_assistance_scheme',
          'name' => 'Financial Assistance Scheme',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'FAS',
          'category' => nil
        },
        {
          'label' => 'flat_rate_maintenance',
          'name' => 'Flat Rate Maintenance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'FRM',
          'category' => nil
        },
        {
          'label' => 'guaranteed_min_pension',
          'name' => 'Guaranteed Minimum Pension',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'GMP',
          'category' => nil
        },
        {
          'label' => 'industrial_death_benefit',
          'name' => 'Industrial Death Benefit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'IDB',
          'category' => nil
        },
        {
          'label' => 'retirement_allowance',
          'name' => 'Retirement Allowance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'RA',
          'category' => nil
        },
        {
          'label' => 'severe_disability_premium',
          'name' => 'Severe Disability Premium',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'SDP',
          'category' => nil
        },
        {
          'label' => 'armed_forces_independence_payment',
          'name' => 'Armed Forces Independence Payment',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'AFIP',
          'category' => 'other'
        },
        {
          'label' => 'state_pension_credit',
          'name' => 'State Pension Credit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'SPC',
          'category' => nil
        },
        {
          'label' => 'state_second_pension',
          'name' => 'State Second Pension',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'S2P',
          'category' => nil
        },
        {
          'label' => 'statutory_maternity_pay',
          'name' => 'Statutory Maternity Pay',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'SMP',
          'category' => nil
        },
        {
          'label' => 'statutory_sick_pay',
          'name' => 'Statutory Sick Pay',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'SSP',
          'category' => nil
        },
        {
          'label' => 'sure_start_mat_grant',
          'name' => 'Sure Start Maternity Grant',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'SSMG',
          'category' => nil
        },
        {
          'label' => 'tax_credit',
          'name' => 'Tax Credit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'TC',
          'category' => nil
        },
        {
          'label' => 'unemploy_supplement',
          'name' => 'Unemployability Supplement',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'US',
          'category' => nil
        },
        {
          'label' => 'work_related_act_comp',
          'name' => 'Work related activity component',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'WRAC',
          'category' => nil
        },
        {
          'label' => 'working_tax_credit',
          'name' => 'Working Tax Credit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'WTC',
          'category' => nil
        },
        {
          'label' => 'attendance_allowance',
          'name' => 'Attendance Allowance',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'AA',
          'category' => 'carer_disability'
        },
        {
          'label' => 'benefit_transfer_advance',
          'name' => 'Benefit Transfer Advance (Universal Credit)',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'low_income'
        },
        {
          'label' => 'budget_advances',
          'name' => 'Budgeting Advance',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'low_income'
        },
        {
          'label' => 'budgeting_loans',
          'name' => 'Budgeting Loans',
          'exclude_from_gross_income' => false,
          'dwp_code' => nil,
          'category' => nil
        },
        {
          'label' => 'carers_allowance',
          'name' => "Carer's Allowance",
          'exclude_from_gross_income' => true,
          'dwp_code' => 'CA',
          'category' => 'carer_disability'
        },
        {
          'label' => 'child_supp_maintenance',
          'name' => 'Child support maintenance',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CSM',
          'category' => nil
        },
        {
          'label' => 'child_tax_credit',
          'name' => 'Child tax credit',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'CTC',
          'category' => nil
        },
        {
          'label' => 'community_care_dp',
          'name' => 'Community Care Direct Payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'carer_disability'
        },
        {
          'label' => 'constant_attendance_allowance',
          'name' => 'Constant Attendance Allowance',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'CAA',
          'category' => 'carer_disability'
        },
        {
          'label' => 'council_tax_benefit',
          'name' => 'Council Tax Reduction',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'CTB',
          'category' => 'low_income'
        },
        {
          'label' => 'disability_living_allowance',
          'name' => 'Disability Living Allowance',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'DLA',
          'category' => 'carer_disability'
        },
        {
          'label' => 'earnings_top_up',
          'name' => 'Earnings top-up (ETU)',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'low_income'
        },
        {
          'label' => 'employment_support_allowance',
          'name' => 'Employment and Support Allowance (ESA)',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'ESA',
          'category' => nil
        },
        {
          'label' => 'exceptionally_severe_disablement_allowance',
          'name' => 'Exceptionally Severe Disablement Allowance',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'ESDA',
          'category' => 'carer_disability'
        },
        {
          'label' => 'fostering_allowance',
          'name' => "Foster Carers' allowance",
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'other'
        },
        {
          'label' => 'graduated_retirement_benefit',
          'name' => 'Graduated Retirement Benefit ',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'GRB',
          'category' => nil
        },
        {
          'label' => 'grenfell_payments',
          'name' => 'Grenfell Tower fire victims payments ',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'other'
        },
        {
          'label' => 'guardians_allowance',
          'name' => "Guardian's Allowance",
          'exclude_from_gross_income' => false,
          'dwp_code' => 'GA',
          'category' => nil
        },
        {
          'label' => 'housing_benefit',
          'name' => 'Housing Benefit',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'HB',
          'category' => 'low_income'
        },
        {
          'label' => 'housing_costs_cont',
          'name' => 'Housing Costs Contribution',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'HCC',
          'category' => nil
        },
        {
          'label' => 'housing_costs_element',
          'name' => 'Housing Costs Element',
          'exclude_from_gross_income' => false,
          'dwp_code' => 'HCE',
          'category' => nil
        },
        {
          'label' => 'independent_living_funds_payments',
          'name' => 'Independent Living Funds payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'carer_disability'
        },
        {
          'label' => 'payments_on_account_of_benefit',
          'name' => 'Payments on account of benefit',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'POAOB',
          'category' => 'carer_disability'
        },
        {
          'label' => 'personal_independent_payments',
          'name' => 'Personal Independent Payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'PIP',
          'category' => 'carer_disability'
        },
        {
          'label' => 'social_fund_funeral_payment',
          'name' => 'Social Fund Funeral Payment',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'SFFP',
          'category' => 'low_income'
        },
        {
          'label' => 'social_fund_payments',
          'name' => 'Social Fund payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'SF',
          'category' => 'low_income'
        },
        {
          'label' => 'special_education_needs',
          'name' => 'Special Education Needs (SEN) direct payment',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'carer_disability'
        },
        {
          'label' => 'war_pension',
          'name' => 'War Pensions Scheme payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'other'
        },
        {
          'label' => 'war_widows_pension',
          'name' => 'War Widow(er) Pension',
          'exclude_from_gross_income' => true,
          'dwp_code' => 'WWP',
          'category' => 'other'
        },
        {
          'label' => 'welsh_independent_living_grant',
          'name' => 'Welsh Independent Living Grant',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'carer_disability'
        },
        {
          'label' => 'widows_pension_lump_sum',
          'name' => 'Widow’s Pension lump sum payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'other'
        },
        {
          'label' => 'windrush',
          'name' => 'Windrush Compensation Scheme payments',
          'exclude_from_gross_income' => true,
          'dwp_code' => nil,
          'category' => 'other'
        }
      ]
    end
  end
end
