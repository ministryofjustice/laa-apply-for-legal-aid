class ApplicantAccountPresenter
  attr_reader :bank_provider

  delegate :name, :bank_accounts, to: :bank_provider

  def initialize(bank_provider)
    @bank_provider = bank_provider
  end

  delegate :main_account_holder, to: :@bank_provider

  def main_account_holder_name
    main_account_holder&.full_name
  end

  def main_account_holder_address
    return nil unless main_account_holder && main_account_holder.addresses

    main_account_holder.addresses.first.values.join(", ")
  end
end
