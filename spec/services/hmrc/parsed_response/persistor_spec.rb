require "rails_helper"

RSpec.describe HMRC::ParsedResponse::Persistor do
  subject(:persistor) { described_class.call(hmrc_response) }

  let(:application) { create(:legal_aid_application, :with_applicant) }
  let(:applicant) { application.applicant }

  describe ".call" do
    context "with invalid HMRC response" do
      before { allow(HMRC::ParsedResponse::Validator).to receive(:call).and_return(false) }

      let(:hmrc_response) { create(:hmrc_response, :example1_usecase1, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }

      it "does not create employment records" do
        expect { persistor }.not_to change { application.employments.count }
      end
    end

    context "with valid HMRC response" do
      before { allow(HMRC::ParsedResponse::Validator).to receive(:call).and_return(true) }

      context "when no employment records exist and HMRC response contains one employment" do
        let(:hmrc_response) { create(:hmrc_response, :example1_usecase1, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }

        it "creates one employment record" do
          expect { persistor }.to change { application.employments.count }.from(0).to(1)
        end

        it "creates 4 employment payment records with the expected data" do
          persistor
          payments = application.employments.first.employment_payments.order(:date)
          expect(payments.size).to eq 4

          expect(payments[0]).to have_attributes(date: Date.parse("2021-08-28"),
                                                 gross: 2345.29,
                                                 benefits_in_kind: 0.0,
                                                 national_insurance: -185.79,
                                                 tax: -257.20,
                                                 net_employment_income: 1902.3)

          expect(payments[1]).to have_attributes(date: Date.parse("2021-09-28"),
                                                 gross: 2492.61,
                                                 benefits_in_kind: 0.0,
                                                 national_insurance: -203.47,
                                                 tax: -286.6,
                                                 net_employment_income: 2002.54)

          expect(payments[2]).to have_attributes(date: Date.parse("2021-10-28"),
                                                 gross: 1868.98,
                                                 benefits_in_kind: 0.0,
                                                 national_insurance: -128.64,
                                                 tax: -111,
                                                 net_employment_income: 1629.34)

          expect(payments[3]).to have_attributes(date: Date.parse("2021-11-28"),
                                                 gross: 1868.98,
                                                 benefits_in_kind: 0.0,
                                                 national_insurance: -128.64,
                                                 tax: -161.8,
                                                 net_employment_income: 1578.54)
        end
      end

      context "when no employment records exist and HMRC response contains multiple employments" do
        let(:hmrc_response) { create(:hmrc_response, :multiple_employments_usecase1, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }

        it "creates 2 employment records" do
          expect { persistor }.to change { application.employments.count }.from(0).to(2)
        end

        it "attaches the 4 employment payment records to only one of the employments" do
          persistor
          employments = application.employments.order(:name)
          expect(employments.first.employment_payments.size).to eq 4
          expect(employments.last.employment_payments.size).to eq 0
        end
      end

      context "when employment and employment payment records already exist for this application" do
        let(:hmrc_response) { create(:hmrc_response, :example1_usecase1, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }
        let(:employment) { create(:employment, legal_aid_application: application, owner_id: applicant.id, owner_type: applicant.class) }

        let(:employment_payment1) { create(:employment_payment, employment:) }
        let(:employment_payment2) { create(:employment_payment, employment:) }
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
end
