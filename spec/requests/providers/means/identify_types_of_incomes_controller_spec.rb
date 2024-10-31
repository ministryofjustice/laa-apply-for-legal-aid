require "rails_helper"

RSpec.describe Providers::Means::IdentifyTypesOfIncomesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  let!(:outgoing_types) do
    [
      create(:transaction_type, :rent_or_mortgage),
      create(:transaction_type, :maintenance_out),
      create(:transaction_type, :child_care),
    ]
  end

  let!(:income_types) do
    [
      create(:transaction_type, :benefits),
      create(:transaction_type, :pension),
      create(:transaction_type, :maintenance_in),
    ]
  end

  let(:non_child_income_types) { income_types.reject(&:child?) }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/means/identify_types_of_income" do
    subject(:request) { get providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application) }

    it "returns http success" do
      request
      expect(response).to have_http_status(:ok)
    end

    it "displays the income type labels" do
      request
      non_child_income_types.map(&:providers_label_name).each do |label|
        expect(unescaped_response_body).to include(label)
      end
      expect(unescaped_response_body).not_to include("translation missing")
    end

    it "does not display expanded details list" do
      request
      expect(unescaped_response_body).not_to match("Why am I being asked this?")
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { request }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/identify_types_of_income" do
    subject(:request) do
      patch(
        providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application),
        params: params.merge(submit_button),
      )
    end

    let(:submit_button) { {} }
    let(:params) do
      {
        legal_aid_application: {
          applicant_transaction_type_ids:,
        },
      }
    end

    context "when no transaction types selected" do
      let(:applicant_transaction_type_ids) { [] }

      it "does not add transaction types to the application" do
        expect { request }.not_to change(legal_aid_application.legal_aid_application_transaction_types, :count)
      end

      it "displays an error" do
        request
        expect(response.body).to match("govuk-error-summary")
        expect(unescaped_response_body).to match("Select if your client receives any types of income")
        expect(unescaped_response_body).not_to include("translation missing")
      end

      it "returns http success" do
        request
        expect(response).to have_http_status(:ok)
      end
    end

    context "when transaction types selected" do
      let(:applicant_transaction_type_ids) { income_types.map(&:id) }

      it "adds transaction types to the application" do
        expect { request }.to change(LegalAidApplicationTransactionType, :count).by(income_types.length)
        expect(legal_aid_application.reload.transaction_types).to match_array(income_types)
      end

      it "sets no_credit_transaction_types_selected to false" do
        expect { request }.to change { legal_aid_application.reload.no_credit_transaction_types_selected }.to(false)
      end

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end

      it "creates a legal_aid_application_transaction_types record with ownership" do
        expect { request }.to change(legal_aid_application.legal_aid_application_transaction_types, :count).by(3)
        expect(legal_aid_application.legal_aid_application_transaction_types.first.owner_type).to eq "Applicant"
      end
    end

    context "when application has transaction types of other kind" do
      let(:applicant_transaction_type_ids) { [] }
      let(:other_transaction_type) { create(:transaction_type, :debit) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, transaction_types: [other_transaction_type]) }

      it "does not remove existing transaction of other type" do
        expect { request }.not_to change { legal_aid_application.transaction_types.count }
      end

      it "does not delete transaction types" do
        expect { request }.not_to change(TransactionType, :count)
      end
    end

    context "when no option has been chosen" do
      let(:params) { { legal_aid_application: { applicant_transaction_type_ids: [] } } }

      it "displays an error" do
        request
        expect(page).to have_content("Select if your client receives any types of income")
      end

      it "does not add transaction types to the application" do
        expect { request }.not_to change(LegalAidApplicationTransactionType, :count)
      end

      it "does not change no_credit_transaction_types_selected" do
        expect { request }.not_to change { legal_aid_application.reload.no_credit_transaction_types_selected }
      end
    end

    context 'when "none selected" has been selected' do
      let(:params) { { legal_aid_application: { none_selected: "true" } } }

      it "sets no_credit_transaction_types_selected to true" do
        expect { request }.to change { legal_aid_application.reload.no_credit_transaction_types_selected }.to(true)
      end

      it "does not add transaction types to the application" do
        expect { request }.not_to change(legal_aid_application.legal_aid_application_transaction_types, :count)
      end

      it "redirects to the next page" do
        request
        expect(response).to have_http_status(:redirect)
      end

      context "when application has existing transaction categories" do
        let(:legal_aid_application) do
          create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: income_types + outgoing_types)
        end

        it "removes credit transaction types from the application" do
          expect { request }.to change(legal_aid_application.legal_aid_application_transaction_types, :count).by(-3)
        end
      end

      context "with existing credit and debit cash transactions" do
        let(:benefits_credit) { create(:transaction_type, :benefits) }
        let(:rent_or_mortgage_debit) { create(:transaction_type, :rent_or_mortgage) }

        let(:legal_aid_application) do
          laa = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [benefits_credit, rent_or_mortgage_debit])
          applicant_id = laa.applicant.id
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 101, month_number: 1, transaction_date: Time.zone.now.to_date)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 102, month_number: 2, transaction_date: 1.month.ago)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 103, month_number: 3, transaction_date: 2.months.ago)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 301, month_number: 1, transaction_date: Time.zone.now.to_date)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 302, month_number: 2, transaction_date: 1.month.ago)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 303, month_number: 3, transaction_date: 2.months.ago)
          laa
        end

        it "removes all credit cash transactions" do
          expect { request }.to change { legal_aid_application.cash_transactions.credits.present? }.from(true).to(false)
        end

        it "does not remove any debit cash transactions" do
          expect { request }.not_to change { legal_aid_application.cash_transactions.debits.present? }.from(true)
        end
      end
    end

    context 'when "none selected" and another type has been selected' do
      let(:params) do
        {
          legal_aid_application: {
            none_selected: "true",
            applicant_transaction_type_ids: income_types.map(&:id),
          },
        }
      end

      it "displays an error" do
        request
        expect(page).to have_content("If you select 'My client does not get any of these payments', you cannot select any of the other options")
      end

      it "synchronizes transaction types to the application" do
        expect { request }.to change(LegalAidApplicationTransactionType, :count)
      end

      it "does not change no_credit_transaction_types_selected" do
        expect { request }.not_to change { legal_aid_application.reload.no_credit_transaction_types_selected }
      end
    end

    context "when existing transaction types are deselected" do
      let(:applicant_transaction_type_ids) { [friends_or_family_credit.id] }

      let(:benefits_credit) { create(:transaction_type, :benefits) }
      let(:friends_or_family_credit) { create(:transaction_type, :friends_or_family) }
      let(:rent_or_mortgage_debit) { create(:transaction_type, :rent_or_mortgage) }

      let(:legal_aid_application) do
        laa = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [benefits_credit, friends_or_family_credit, rent_or_mortgage_debit])
        applicant_id = laa.applicant.id
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 101, month_number: 1, transaction_date: Time.zone.now.to_date)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 102, month_number: 2, transaction_date: 1.month.ago)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 103, month_number: 3, transaction_date: 2.months.ago)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: friends_or_family_credit.id, amount: 201, month_number: 1, transaction_date: Time.zone.now.to_date)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: friends_or_family_credit.id, amount: 202, month_number: 2, transaction_date: 1.month.ago)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: friends_or_family_credit.id, amount: 203, month_number: 3, transaction_date: 2.months.ago)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 301, month_number: 1, transaction_date: Time.zone.now.to_date)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 302, month_number: 2, transaction_date: 1.month.ago)
        laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 303, month_number: 3, transaction_date: 2.months.ago)
        laa
      end

      it "synchronizes credit transaction types" do
        expect(legal_aid_application.legal_aid_application_transaction_types.credits.map(&:transaction_type)).to contain_exactly(benefits_credit, friends_or_family_credit)
        request
        expect(legal_aid_application.legal_aid_application_transaction_types.credits.map(&:transaction_type)).to contain_exactly(friends_or_family_credit)
      end

      it "does not remove existing debit transaction types" do
        expect { request }.not_to change(legal_aid_application.legal_aid_application_transaction_types.debits, :count)
      end

      it "synchronizes credit transaction types cash transactions" do
        expect(legal_aid_application.cash_transactions.credits.map(&:transaction_type).uniq).to contain_exactly(benefits_credit, friends_or_family_credit)
        request
        expect(legal_aid_application.cash_transactions.credits.map(&:transaction_type).uniq).to contain_exactly(friends_or_family_credit)
      end

      it "does not remove any debit cash transactions" do
        expect { request }.not_to change(legal_aid_application.cash_transactions.debits, :count)
      end
    end

    context "when the wrong transaction type is passed in" do
      let!(:income_types) { create_list(:transaction_type, 3, :debit_with_standard_name) }
      let(:applicant_transaction_type_ids) { income_types.map(&:id) }

      it "does not add the transaction types" do
        expect { request }.not_to change { legal_aid_application.transaction_types.count }
      end
    end

    context "when benefits selected" do
      let(:applicant_transaction_type_ids) { [benefits.id] }
      let(:benefits) { create(:transaction_type, :benefits) }

      before do
        create(:transaction_type, :excluded_benefits, parent_id: benefits.id)
      end

      it "adds excluded_benefits transaction type as well as benefits" do
        expect { request }.to change(LegalAidApplicationTransactionType, :count).by(2)
        expect(legal_aid_application.reload.transaction_types.pluck(:name)).to match_array(%w[benefits excluded_benefits])
      end
    end

    context "when checking answers" do
      subject(:request) { patch providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application), params: params.merge(submit_button) }

      let(:legal_aid_application) do
        create(:legal_aid_application,
               :with_non_passported_state_machine,
               :checking_means_income,
               :with_applicant)
      end

      let(:params) { { legal_aid_application: { none_selected: "true" } } }

      context "with bank statement upload flow" do
        before do
          legal_aid_application.provider.permissions << Permission.find_or_create_by(role: "application.non_passported.bank_statement_upload.*")
          legal_aid_application.update!(provider_received_citizen_consent: false)
        end

        context "without transaction type credits" do
          before do
            legal_aid_application.transaction_types.credits.destroy_all
          end

          it "redirects to checking answers income" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_check_income_answers_path(legal_aid_application))
          end
        end

        context "with credit transaction types" do
          let(:params) { { legal_aid_application: { applicant_transaction_type_ids: [create(:transaction_type, :credit).id] } } }

          it "redirects to cash_incomes" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_cash_income_path(legal_aid_application))
          end
        end
      end

      context "without bank statement uploads" do
        before do
          legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          legal_aid_application.update!(provider_received_citizen_consent: true)
        end

        context "without credit transaction types" do
          before do
            legal_aid_application.transaction_types.credits.destroy_all
          end

          it "redirects to next page in flow" do
            request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "with credit transaction types" do
          let(:params) { { legal_aid_application: { applicant_transaction_type_ids: [create(:transaction_type, :credit).id] } } }

          it "redirects to cash_incomes" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_means_cash_income_path(legal_aid_application))
          end
        end
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:applicant_transaction_type_ids) { [] }

      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when form submitted with Save as draft button" do
      let(:params) do
        {
          draft_button: "Save as draft",
          legal_aid_application: {
            applicant_transaction_type_ids: [],
          },
        }
      end

      it "redirects to the list of applications" do
        request
        expect(response).to redirect_to submitted_providers_legal_aid_applications_path
      end

      context "with existing credit and debit cash transactions" do
        let(:benefits_credit) { create(:transaction_type, :benefits) }
        let(:rent_or_mortgage_debit) { create(:transaction_type, :rent_or_mortgage) }

        let(:legal_aid_application) do
          laa = create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [benefits_credit, rent_or_mortgage_debit])
          applicant_id = laa.applicant.id
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 101, month_number: 1, transaction_date: Time.zone.now.to_date)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 102, month_number: 2, transaction_date: 1.month.ago)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: benefits_credit.id, amount: 103, month_number: 3, transaction_date: 2.months.ago)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 301, month_number: 1, transaction_date: Time.zone.now.to_date)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 302, month_number: 2, transaction_date: 1.month.ago)
          laa.cash_transactions.create!(owner_type: "Applicant", owner_id: applicant_id, transaction_type_id: rent_or_mortgage_debit.id, amount: 303, month_number: 3, transaction_date: 2.months.ago)
          laa
        end

        it "removes all credit cash transactions" do
          expect { request }.to change { legal_aid_application.cash_transactions.credits.present? }.from(true).to(false)
        end

        it "does not remove any debit cash transactions" do
          expect { request }.not_to change { legal_aid_application.cash_transactions.debits.present? }.from(true)
        end
      end
    end
  end
end
