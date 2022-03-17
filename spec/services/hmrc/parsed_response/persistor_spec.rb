require "rails_helper"

RSpec.describe HMRC::ParsedResponse::Persistor do
  let(:application) { hmrc_response.legal_aid_application }

  subject(:persistor) { described_class.call(application) }

  describe ".call" do
    context "when no employment records exist" do
      context "when HMRC response contains one employment" do
        let!(:hmrc_response) { create :hmrc_response, :example1_usecase1 }

        it "creates one employment record" do
          persistor
          expect(application.employments.count).to eq 1
        end

        it "creates 4 employment payment records with the expected data" do
          persistor
          payments = application.employments.first.employment_payments.order(:date)
          expect(payments.size).to eq 4

          expect(payments[0].date).to eq Date.parse("2021-08-28")
          expect(payments[0].gross).to eq 2345.29
          expect(payments[0].benefits_in_kind).to eq 0.0
          expect(payments[0].national_insurance).to eq(-185.79)
          expect(payments[0].tax).to eq(-257.20)
          expect(payments[0].net_employment_income).to eq 1902.3

          expect(payments[1].date).to eq Date.parse("2021-09-28")
          expect(payments[1].gross).to eq 2492.61
          expect(payments[1].benefits_in_kind).to eq 0.0
          expect(payments[1].national_insurance).to eq(-203.47)
          expect(payments[1].tax).to eq(-286.6)
          expect(payments[1].net_employment_income).to eq 2002.54

          expect(payments[2].date).to eq Date.parse("2021-10-28")
          expect(payments[2].gross).to eq 1868.98
          expect(payments[2].benefits_in_kind).to eq 0.0
          expect(payments[2].national_insurance).to eq(-128.64)
          expect(payments[2].tax).to eq(-111)
          expect(payments[2].net_employment_income).to eq 1629.34

          expect(payments[3].date).to eq Date.parse("2021-11-28")
          expect(payments[3].gross).to eq 1868.98
          expect(payments[3].benefits_in_kind).to eq 0.0
          expect(payments[3].national_insurance).to eq(-128.64)
          expect(payments[3].tax).to eq(-161.8)
          expect(payments[3].net_employment_income).to eq 1578.54
        end
      end
      context "when HMRC response contains multiple employments" do
        let(:hmrc_response) { create :hmrc_response, :multiple_employments_usecase1 }

        it "creates 2 employment records" do
          persistor
          expect(application.employments.size).to eq 2
        end

        it "attaches the 4 employment payment records to only one of the employments" do
          persistor
          employments = application.employments.order(:name)
          expect(employments.first.employment_payments.size).to eq 4
          expect(employments.last.employment_payments.size).to eq 0
        end
      end
    end

    context "when employment and employment payment records already exist for this application" do
      let(:hmrc_response) { create :hmrc_response, :example1_usecase1 }
      let(:employment) { create :employment, legal_aid_application: application }

      let(:employment_payment1) { create :employment_payment, employment: employment }
      let(:employment_payment2) { create :employment_payment, employment: employment }
      let!(:employment_payment_ids) { [employment_payment1.id, employment_payment2.id] }
      let!(:emp_id) { employment.id }

      it "deletes the existing employment record" do
        expect(Employment.find(emp_id)).to be_instance_of(Employment)
        persistor
        expect { Employment.find(emp_id) }.to raise_error ActiveRecord::RecordNotFound
      end

      it "deletes the existing records" do
        expect(EmploymentPayment.find(employment_payment_ids).size).to eq 2
        persistor
        ids = EmploymentPayment.pluck(:id)
        expect(ids).not_to include(employment_payment_ids.first)
        expect(ids).not_to include(employment_payment_ids.last)
      end

      it "creates a new employment record" do
        persistor
        expect(application.employments.size).to eq 1
      end

      it "creates 4 new employment payment records" do
        persistor
        expect(application.employments.first.employment_payments.size).to eq 4
      end
    end
  end
end
