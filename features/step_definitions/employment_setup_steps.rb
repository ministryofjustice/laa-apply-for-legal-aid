Given(/^an applicant named (\S+) (\S+) has completed his true layer interaction$/) do |first_name, last_name|
  @applicant = FactoryBot.create :applicant,
                                 :employed,
                                 "#{first_name}_#{last_name}".downcase.to_sym,
                                 with_bank_accounts: 1
  FactoryBot.create :address, applicant: @applicant
  @legal_aid_application = FactoryBot.create :legal_aid_application,
                                             :non_passported,
                                             :with_everything,
                                             :provider_assessing_means,
                                             :with_proceedings,
                                             without_vehicle: true,
                                             applicant: @applicant,
                                             provider_step: "client_completed_means",
                                             provider: @registered_provider
  bank_account = @applicant.bank_accounts.first
  FactoryBot.create_list :bank_transaction, 2, :credit, bank_account:, amount: rand(1...1_500.0).round(2)
  FactoryBot.create_list :bank_transaction, 3, :debit, bank_account:,  amount: rand(1...1_500.0).round(2)
  create(:legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application)
  HMRC::CreateResponsesService.call(@legal_aid_application)
  sleep 0.5 # give time for the after_update on HMRC::Response to do its thing
end
