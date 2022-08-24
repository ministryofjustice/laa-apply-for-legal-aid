Given(/^the system is prepped for the employed journey$/) do
  employment_permission = Permission.find_by(role: "application.non_passported.employment.*")
  Provider.all.each do |provider|
    next if provider.permissions.include?(employment_permission)

    provider.permissions << employment_permission
    provider.save!
  end
end

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
                                             applicant: @applicant,
                                             provider_step: "client_completed_means",
                                             provider: @registered_provider
  bank_account = @applicant.bank_accounts.first
  FactoryBot.create_list :bank_transaction, 2, :credit, bank_account: bank_account, amount: rand(1...1_500.0).round(2)
  FactoryBot.create_list :bank_transaction, 3, :debit, bank_account: bank_account,  amount: rand(1...1_500.0).round(2)

  HMRC::CreateResponsesService.call(@legal_aid_application)
  sleep 0.5 # give time for the after_update on HMRC::Response to do its thing
end
