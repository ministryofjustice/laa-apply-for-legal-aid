class TestApplicationCreationService
  APPLICATION_TEST_TRAITS = %i[
    test_application_initiated
    test_application_checking_answers
    test_application_checking_passported_answers
    test_application_answers_checked
    test_application_provider_submitted
    test_application_means_completed
    test_application_chekcing_merits_answers
  ].freeze

  PROVIDERS = Provider.all

  def self.call
    new.call
  end

  def initialize
    @providers = Provider.all
  end

  def call
    @providers.each do |provider|
      APPLICATION_TEST_TRAITS.each do |trait|
        create_test_application(provider, trait)
      end
    end
  end

  private

  def create_test_application(provider, trait)
    FactoryBot.create(
      :application,
      :with_applicant,
      trait,
      provider: provider
    )
  end
end
