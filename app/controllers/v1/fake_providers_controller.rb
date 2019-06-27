module V1
  class FakeProvidersController < ApiController
    def show
      render json: provider_details
    end

    private

    def provider_details
      {
        providerOffices: Array.new(rand(1..3)).map { provider_office },
        contactId: rand(1..100_000),
        contactName: params[:username]
      }
    end

    def provider_office
      {
        providerfirmId: firm_id,
        officeId: rand(1..100_000),
        officeName: Faker::Lorem.sentence,
        smsVendorNum: rand(1..10_000).to_s,
        smsVendorSite: Faker::Lorem.word
      }
    end

    def firm_id
      @firm_id ||= rand(1..100_000)
    end
  end
end
