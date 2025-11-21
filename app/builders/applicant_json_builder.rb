class ApplicantJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      first_name:,
      date_of_birth:,
      created_at:,
      updated_at:,
      last_name:,
      email:,
      national_insurance_number:,
      # confirmation_token:,
      # confirmed_at:,
      # confirmation_sent_at:,
      # failed_attempts:,
      # unlock_token:,
      # locked_at:,
      employed:,
      # remember_created_at:,
      # remember_token:,
      self_employed:,
      armed_forces:,
      has_national_insurance_number:,
      age_for_means_test_purposes:,
      # encrypted_true_layer_token:,
      has_partner:,
      receives_state_benefits:,
      partner_has_contrary_interest:,
      student_finance:,
      student_finance_amount:,
      extra_employment_information:,
      extra_employment_information_details:,
      last_name_at_birth:,
      changed_last_name:,
      same_correspondence_and_home_address:,
      no_fixed_residence:,
      correspondence_address_choice:,
      shared_benefit_with_partner:,
      applied_previously:,
      previous_reference:,
      relationship_to_children:,
      addresses: addresses.map { |a| AddressJsonBuilder.build(a).as_json },
      # bank_providers: bank_providers.map { |bp| BankProviderJsonBuilder.build(bp).as_json }, Moved to LegalAidApplicationJsonBuilder to group with means??
    }
  end

  # has_one :legal_aid_application, dependent: :destroy
  # has_many :addresses, dependent: :destroy
  # has_one :address, -> { where(location: "correspondence").order(created_at: :desc) }, inverse_of: :applicant, dependent: :destroy
  # has_one :home_address, -> { where(location: "home").order(created_at: :desc) }, class_name: "Address", inverse_of: :applicant, dependent: :destroy
  # has_many :bank_providers, dependent: :destroy
  # has_many :bank_errors, dependent: :destroy
  # has_many :bank_accounts, through: :bank_providers
  # has_many :bank_transactions, through: :bank_accounts
  # has_many :regular_transactions, as: :owner
  # has_many :hmrc_responses, class_name: "HMRC::Response", as: :owner
  # has_many :employments, as: :owner
end
