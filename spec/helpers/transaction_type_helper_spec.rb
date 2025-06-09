require "rails_helper"

RSpec.describe TransactionTypeHelper do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:owner_type) { "Applicant" }

  describe "#answer_for_transaction_type" do
    subject do
      transaction_type = instance_double(TransactionType, id: "a-stubbed-uuid")

      helper.answer_for_transaction_type(legal_aid_application:,
                                         transaction_type:,
                                         owner_type:)
    end

    context "when on bank statement upload journey" do
      before do
        allow(legal_aid_application).to receive(:client_uploading_bank_statements?).and_return(true)
      end

      context "with transaction types with positive amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 1)
        end

        it { is_expected.to eql("Yes") }
      end

      context "with transaction types with zero amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 0)
        end

        it { is_expected.to eql("Yes") }
      end

      context "without transaction types" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: false, transactions_total_by_category: "irrelevant-but-stub-needed")
        end

        it { is_expected.to eql("None") }
      end
    end

    context "when not on bank statement upload journey" do
      before do
        allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false)
      end

      context "with transaction types with positive amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 123.45)
        end

        it { is_expected.to eql("£123.45") }
      end

      context "with transaction types with zero amounts" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: true, transactions_total_by_category: 0)
        end

        it { is_expected.to eql("Yes, but none specified") }
      end

      context "without transaction types" do
        before do
          allow(legal_aid_application).to receive_messages(has_transaction_type?: false, transactions_total_by_category: "irrelevant-but-stub-needed")
        end

        it { is_expected.to eql("None") }
      end
    end
  end

  describe "#regular_transaction_answer_by_type" do
    subject do
      helper.regular_transaction_answer_by_type(legal_aid_application:,
                                                transaction_type: benefits,
                                                owner_type: "Applicant")
    end

    let(:benefits) { create(:transaction_type, :benefits) }

    context "when regular transactions exist" do
      before do
        create(:regular_transaction,
               legal_aid_application:,
               transaction_type: benefits,
               owner_type: "Applicant",
               amount: 250,
               frequency: "weekly")
      end

      it { is_expected.to eq(["£250", "every week"]) }
    end

    context "when no regular transactions exist" do
      it { is_expected.to eql("None") }
    end
  end

  describe "#format_transactions" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :without_open_banking_consent) }
    let(:formatted_transactions) do
      helper.format_transactions(legal_aid_application:, credit_or_debit:, regular_or_cash:, individual:)
    end

    context "with incoming regular payments" do
      let(:credit_or_debit) { :credit }
      let(:regular_or_cash) { :regular }

      before do
        create(:regular_transaction, :maintenance_in, legal_aid_application:, owner_type: individual)
        create(:regular_transaction, :friends_or_family, legal_aid_application:, owner_type: individual)
        create(:transaction_type, :property_or_lodger)
        create(:transaction_type, :pension)
      end

      context "and individual is applicant" do
        let(:individual) { "Applicant" }

        context "with bank statement upload" do
          it "returns a hash of formatted key value pairs" do
            expect(formatted_transactions).to contain_exactly(
              { label: "Financial help from friends or family", value: "£500 every week" },
              { label: "Maintenance payments from a former partner", value: "£500 every week" },
              { label: "Income from a property or lodger", value: "None" },
              { label: "Pension", value: "None" },
            )
          end

          context "and with incoming cash payments" do
            let(:regular_or_cash) { :cash }

            before do
              create(:cash_transaction, :maintenance_in, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                         transaction_date: Date.new(2021, 1, 1), month_number: 1, amount: 111.0)
              create(:cash_transaction, :maintenance_in, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                         transaction_date: Date.new(2021, 2, 1), month_number: 2, amount: 222.0)
              create(:cash_transaction, :maintenance_in, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                         transaction_date: Date.new(2021, 3, 1), month_number: 3, amount: 333.0)
            end

            it "returns a hash of formatted key value pairs for categories which have either regular or cash transactions" do
              expect(formatted_transactions).to contain_exactly(
                { label: "Financial help from friends or family", value: "None" },
                { label: "Maintenance payments from a former partner", value: "£111 in January 2021<br>£222 in February 2021<br>£333 in March 2021" },
              )
            end
          end
        end

        context "with truelayer journey and incoming cash transactions and bank transactions" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_open_banking_consent, with_bank_accounts: 1) }
          let(:benefits) { create(:transaction_type, :benefits) }

          before do
            create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: benefits, owner_type: individual)

            create(:cash_transaction, :benefits, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                 transaction_date: Date.new(2021, 1, 1), month_number: 1, amount: 1.0)
            create(:cash_transaction, :benefits, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                 transaction_date: Date.new(2021, 2, 1), month_number: 2, amount: 2.0)
            create(:cash_transaction, :benefits, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                 transaction_date: Date.new(2021, 3, 1), month_number: 3, amount: 3.0)
            create(:bank_transaction, :benefits, happened_at: Date.new(2021, 1, 1), amount: 100, bank_account: legal_aid_application.applicant.bank_accounts.first)
          end

          it "returns a hash of formatted key value pairs" do
            expect(formatted_transactions).to contain_exactly(
              { label: "Financial help from friends or family", value: "None" },
              { label: "Benefits, charitable or government payments", value: "£106" },
              { label: "Maintenance payments from a former partner", value: "None" },
              { label: "Income from a property or lodger", value: "None" },
              { label: "Pension", value: "None" },
            )
          end
        end
      end

      context "and individual is partner" do
        let(:individual) { "Partner" }

        it "returns a hash of formatted key value pairs" do
          expect(formatted_transactions).to contain_exactly(
            { label: "Financial help from friends or family", value: "£500 every week" },
            { label: "Maintenance payments from a former partner", value: "£500 every week" },
            { label: "Income from a property or lodger", value: "None" },
            { label: "Pension", value: "None" },
          )
        end

        context "and with incoming cash payments" do
          let(:regular_or_cash) { :cash }

          before do
            create(:cash_transaction, :maintenance_in, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.partner.id,
                                                       transaction_date: Date.new(2021, 1, 1), month_number: 1, amount: 111.0)
            create(:cash_transaction, :maintenance_in, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.partner.id,
                                                       transaction_date: Date.new(2021, 2, 1), month_number: 2, amount: 222.0)
            create(:cash_transaction, :maintenance_in, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.partner.id,
                                                       transaction_date: Date.new(2021, 3, 1), month_number: 3, amount: 333.0)
          end

          it "returns a hash of formatted key value pairs" do
            expect(formatted_transactions).to contain_exactly(
              { label: "Financial help from friends or family", value: "None" },
              { label: "Maintenance payments from a former partner", value: "£111 in January 2021<br>£222 in February 2021<br>£333 in March 2021" },
            )
          end
        end
      end
    end

    context "with outgoing regular payments" do
      let(:credit_or_debit) { :debit }
      let(:regular_or_cash) { :regular }

      before do
        create(:regular_transaction, :rent_or_mortgage, legal_aid_application:, owner_type: individual)
        create(:transaction_type, :child_care)
        create(:regular_transaction, :maintenance_out, legal_aid_application:, owner_type: individual)
        create(:transaction_type, :legal_aid)
      end

      context "and individual is applicant" do
        let(:individual) { "Applicant" }

        context "with bank statement upload" do
          it "returns a hash of formatted key value pairs" do
            expect(formatted_transactions).to contain_exactly(
              { label: "Housing payments", value: "£500 every week" },
              { label: "Maintenance payments to a former partner", value: "£500 every week" },
              { label: "Childcare payments", value: "None" },
              { label: "Payments towards legal aid in a criminal case", value: "None" },
            )
          end

          context "and with outgoing cash payments" do
            let(:regular_or_cash) { :cash }

            before do
              create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                          transaction_date: Date.new(2021, 1, 1), month_number: 1, amount: 111.0)
              create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                          transaction_date: Date.new(2021, 2, 1), month_number: 2, amount: 222.0)
              create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                          transaction_date: Date.new(2021, 3, 1), month_number: 3, amount: 333.0)
            end

            it "returns a hash of formatted key value pairs" do
              expect(formatted_transactions).to contain_exactly(
                { label: "Housing payments", value: "None" },
                { label: "Maintenance payments to a former partner", value: "£111 in January 2021<br>£222 in February 2021<br>£333 in March 2021" },
              )
            end
          end
        end

        context "with truelayer journey and outgoing cash transactions and bank transactions" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_open_banking_consent, with_bank_accounts: 1) }
          let(:maintenance_out) { TransactionType.find_by(name: "maintenance_out") }

          before do
            create(:legal_aid_application_transaction_type, legal_aid_application:, transaction_type: maintenance_out, owner_type: individual)

            create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                        transaction_date: Date.new(2021, 1, 1), month_number: 1, amount: 1.0)
            create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                        transaction_date: Date.new(2021, 2, 1), month_number: 2, amount: 2.0)
            create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.applicant.id,
                                                        transaction_date: Date.new(2021, 3, 1), month_number: 3, amount: 3.0)
            create(:bank_transaction, :maintenance_out, happened_at: Date.new(2021, 1, 1), amount: 100, bank_account: legal_aid_application.applicant.bank_accounts.first)
          end

          it "returns a hash of formatted key value pairs" do
            expect(formatted_transactions).to contain_exactly(
              { label: "Housing payments", value: "None" },
              { label: "Maintenance payments to a former partner", value: "£106" },
              { label: "Childcare payments", value: "None" },
              { label: "Payments towards legal aid in a criminal case", value: "None" },
            )
          end
        end
      end

      context "and individual is partner" do
        let(:individual) { "Partner" }

        it "returns a hash of formatted key value pairs" do
          expect(formatted_transactions).to contain_exactly(
            { label: "Housing payments", value: "£500 every week" },
            { label: "Maintenance payments to a former partner", value: "£500 every week" },
            { label: "Childcare payments", value: "None" },
            { label: "Payments towards legal aid in a criminal case", value: "None" },
          )
        end

        context "and with outgoing cash payments" do
          let(:regular_or_cash) { :cash }

          before do
            create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.partner.id,
                                                        transaction_date: Date.new(2021, 1, 1), month_number: 1, amount: 111.0)
            create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.partner.id,
                                                        transaction_date: Date.new(2021, 2, 1), month_number: 2, amount: 222.0)
            create(:cash_transaction, :maintenance_out, legal_aid_application:, owner_type: individual, owner_id: legal_aid_application.partner.id,
                                                        transaction_date: Date.new(2021, 3, 1), month_number: 3, amount: 333.0)
          end

          it "returns a hash of formatted key value pairs" do
            expect(formatted_transactions).to contain_exactly(
              { label: "Housing payments", value: "None" },
              { label: "Maintenance payments to a former partner", value: "£111 in January 2021<br>£222 in February 2021<br>£333 in March 2021" },
            )
          end
        end
      end
    end
  end
end
