class TestApplicationCreationService
  APPLICATION_TEST_TRAITS = %i[
    at_initiated
    at_checking_applicant_details
    at_checking_passported_answers
    at_applicant_details_checked
    at_provider_submitted
    at_provider_assessing_means
    at_checking_merits_answers
  ].freeze

  def self.call
    new.call
  end

  def call
    providers.each do |provider|
      APPLICATION_TEST_TRAITS.each do |trait|
        create_test_application(provider, trait)
      end
    end
  end

  private

  def providers
    Provider.all
  end

  def create_test_application(provider, trait)
    FactoryBot.create(
      :application,
      :with_applicant,
      trait,
      provider: provider
    )
  end
end
