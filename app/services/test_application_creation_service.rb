class TestApplicationCreationService
  APPLICATION_TEST_TRAITS = %i[
    at_initiated
    at_checking_applicant_details
    at_checking_passported_answers
    at_applicant_details_checked
    provider_entering_merits
    at_checking_merits_answers
  ].freeze

  NON_PASSPORTED_TEST_TRAITS = %i[
    awaiting_applicant
    applicant_entering_means
  ].freeze

  def self.call
    new.call
  end

  def call
    providers.each do |provider|
      APPLICATION_TEST_TRAITS.each do |trait|
        create_passported_application(provider, trait)
      end

      NON_PASSPORTED_TEST_TRAITS.each do |trait|
        create_non_passported_application(provider, trait)
      end
    end
  end

  private

  def providers
    Provider.all
  end

  def create_passported_application(provider, trait)
    FactoryBot.create(
      :application,
      :with_passported_state_machine,
      :with_applicant,
      trait,
      provider: provider
    )
  end

  def create_non_passported_application(provider, trait)
    FactoryBot.create(
      :application,
      :with_non_passported_state_machine,
      :with_applicant,
      trait,
      provider: provider
    )
  end
end
