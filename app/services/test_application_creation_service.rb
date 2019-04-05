class TestApplicationCreationService
  APPLICATION_TEST_TRAITS = %i[
    at_initiated
    at_checking_client_details_answers
    at_checking_passported_answers
    at_client_details_answers_checked
    at_provider_submitted
    at_means_completed
    at_chekcing_merits_answers
  ].freeze

  def self.call
    new.call
  end

  def providers
    Provider.all
  end

  def call
    providers.each do |provider|
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
