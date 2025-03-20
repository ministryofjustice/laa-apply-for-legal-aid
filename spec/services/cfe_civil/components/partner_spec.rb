require "rails_helper"

RSpec.describe CFECivil::Components::Partner do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) do
    create(:legal_aid_application,
           :with_applicant_and_partner,
           :with_positive_benefit_check_result,
           transaction_period_finish_on: Time.zone.today)
  end

  describe ".call" do
    context "when there is no partner" do
      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_positive_benefit_check_result,
               transaction_period_finish_on: Time.zone.today)
      end

      it "returns an empty json hash" do
        expect(call).to eq({}.to_json)
      end
    end

    it "returns json in the expected format" do
      expect(call).to eq({
        partner: {
          partner: {
            date_of_birth: legal_aid_application.partner.date_of_birth.strftime("%Y-%m-%d"),
          },
          cash_transactions: {
            income: [],
            outgoings: [],
          },
          irregular_incomes: [],
          vehicles: [],
          regular_transactions: [],
          capitals: {
            bank_accounts: [],
            non_liquid_capital: [],
          },
        },
      }.to_json)
    end

    context "when the partner has a vehicle" do
      before do
        create(:vehicle,
               legal_aid_application:,
               estimated_value: 2345.0,
               payment_remaining: 321.0,
               more_than_three_years_old: true,
               used_regularly: true,
               owner: "partner")
      end

      it "returns json in the expected format" do
        expect(call).to eq({
          partner: {
            partner: {
              date_of_birth: legal_aid_application.partner.date_of_birth.strftime("%Y-%m-%d"),
            },
            cash_transactions: {
              income: [],
              outgoings: [],
            },
            irregular_incomes: [],
            vehicles: [
              value: 2345.0,
              loan_amount_outstanding: 321.0,
              date_of_purchase: 4.years.ago.to_date,
              in_regular_use: true,
            ],
            regular_transactions: [],
            capitals: {
              bank_accounts: [],
              non_liquid_capital: [],
            },
          },
        }.to_json)
      end
    end

    context "when the partner has a regular friends and family income" do
      before do
        create(:regular_transaction,
               :friends_or_family,
               legal_aid_application:,
               amount: 501.00,
               frequency: "monthly",
               owner_type: legal_aid_application.partner.class,
               owner_id: legal_aid_application.partner.id)
      end

      it "returns json in the expected format" do
        expect(call).to eq({
          partner: {
            partner: {
              date_of_birth: legal_aid_application.partner.date_of_birth.strftime("%Y-%m-%d"),
            },
            cash_transactions: {
              income: [],
              outgoings: [],
            },
            irregular_incomes: [],
            vehicles: [],
            regular_transactions: [
              {
                category: "friends_or_family",
                operation: "credit",
                amount: 501.00,
                frequency: "monthly",
              },
            ],
            capitals: {
              bank_accounts: [],
              non_liquid_capital: [],
            },
          },
        }.to_json)
      end
    end

    context "when there are partner and joint bank accounts" do
      before do
        create(:savings_amount,
               legal_aid_application:,
               offline_current_accounts: 111,
               offline_savings_accounts: 222,
               partner_offline_current_accounts: 333,
               partner_offline_savings_accounts: 444,
               joint_offline_current_accounts: 555,
               joint_offline_savings_accounts: 666)
      end

      it "returns json in the expected format" do
        expect(call).to eq({
          partner: {
            partner: {
              date_of_birth: legal_aid_application.partner.date_of_birth.strftime("%Y-%m-%d"),
            },
            cash_transactions: {
              income: [],
              outgoings: [],
            },
            irregular_incomes: [],
            vehicles: [],
            regular_transactions: [],
            capitals: {
              bank_accounts: [
                { description: "Partner current accounts", value: "333.0" },
                { description: "Partner savings accounts", value: "444.0" },
                { description: "Joint current accounts", value: "555.0" },
                { description: "Joint savings accounts", value: "666.0" },
              ],
              non_liquid_capital: [],
            },
          },
        }.to_json)
      end
    end

    context "when the partner is employed" do
      before do
        partner = legal_aid_application.partner
        create(:employment, :example2_usecase1, legal_aid_application:, owner_id: partner.id, owner_type: partner.class)
      end

      it "returns json in the expected format" do
        result = JSON.parse(call, symbolize_names: true)

        expect(result).to match hash_including({
          partner: {
            partner: {
              date_of_birth: legal_aid_application.partner.date_of_birth.strftime("%Y-%m-%d"),
            },
            cash_transactions: {
              income: [],
              outgoings: [],
            },
            irregular_incomes: [],
            vehicles: [],
            employments: [
              {
                name: "Job 877",
                client_id: kind_of(String),
                payments: [
                  {
                    client_id: kind_of(String),
                    date: "2021-11-28",
                    gross: 1868.98,
                    benefits_in_kind: 0.0,
                    tax: -161.8,
                    national_insurance: -128.64,
                    net_employment_income: 1578.54,
                  },
                  {
                    client_id: kind_of(String),
                    date: "2021-10-28",
                    gross: 1868.98,
                    benefits_in_kind: 0.0,
                    tax: -111.0,
                    national_insurance: -128.64,
                    net_employment_income: 1629.34,
                  },
                  {
                    client_id: kind_of(String),
                    date: "2021-09-28",
                    gross: 2492.61,
                    benefits_in_kind: 0.0,
                    tax: -286.6,
                    national_insurance: -203.47,
                    net_employment_income: 2002.54,
                  },
                  {
                    client_id: kind_of(String),
                    date: "2021-08-28",
                    gross: 2345.29,
                    benefits_in_kind: 0.0,
                    tax: -257.2,
                    national_insurance: -185.79,
                    net_employment_income: 1902.3,
                  },
                ],
              },
            ],
            regular_transactions: [],
            capitals: {
              bank_accounts: [],
              non_liquid_capital: [],
            },
          },
        })
      end
    end
  end
end
