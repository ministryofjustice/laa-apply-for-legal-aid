When("I visit the check income answers page") do
  visit(providers_legal_aid_application_means_check_income_answers_path(@legal_aid_application))
end

When(/^the client has a (credit|debit) transaction named (.*) categorised as (.*)$/) do |type, description, category|
  bank_account = @legal_aid_application.applicant.bank_accounts.first
  category.gsub!(/\s+/, "_")

  create(:bank_transaction, type.to_sym, category.to_sym, :manually_chosen, bank_account:, amount: 44, description:)
  create(:legal_aid_application_transaction_type,
         legal_aid_application: @legal_aid_application,
         transaction_type: TransactionType.find_by(name: category),
         owner_type: "Applicant",
         owner_id: @legal_aid_application.applicant)
end

When(/the partner has a how much how often payment categorised as (.*)/) do |category|
  @legal_aid_application.transaction_types << (TransactionType.find_by(name: category) || create(:transaction_type, category.to_sym))
  create(:regular_transaction, category.to_sym, legal_aid_application: @legal_aid_application, amount: 50, frequency: "weekly", owner_id: @legal_aid_application.partner.id, owner_type: "Partner")
end
