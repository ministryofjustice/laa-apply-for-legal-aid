When("I visit the check income answers page") do
  visit(providers_legal_aid_application_means_check_income_answers_path(@legal_aid_application))
end

When("the client has a transaction named {string} categorised as \"Financial help from friends or family\"") do |description|
  bank_account = @legal_aid_application.applicant.bank_accounts.first
  create(:bank_transaction, :credit, :friends_or_family, :manually_chosen, bank_account:, amount: 44, description:)
  create(:legal_aid_application_transaction_type,
         legal_aid_application: @legal_aid_application,
         transaction_type: TransactionType.find_by(name: "friends_or_family"),
         owner_type: "Applicant",
         owner_id: @legal_aid_application.applicant)
end

When(/the partner has a how much how many payment categorised as "Maintenance payments from a former partner"/) do
  @legal_aid_application.transaction_types << (TransactionType.find_by(name: "maintenance_in") || create(:transaction_type, :maintenance_in))
  create(:regular_transaction, :maintenance_in, legal_aid_application: @legal_aid_application, amount: 50, frequency: "weekly", owner_id: @legal_aid_application.partner.id, owner_type: "Partner")
end
