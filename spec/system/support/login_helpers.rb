require Rails.root.join("spec/services/pda/provider_details_request_stubs")
module LoginHelpers
  def login_as_a_provider
    @registered_provider = create(:provider, username: "System Tester")
    @registered_provider.office_codes = "0X395U:2N078D:A123456"

    stub_office_schedules_for_0x395u

    stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{@registered_provider.username}")
      .to_return(body: provider_user_body, status: 200)

    allow(ProviderContractDetailsWorker)
      .to receive(:perform_async).and_return(true)

    login_as @registered_provider
  end

private

  def provider_user_body
    {
      user: {
        userId: 98_765,
        ccmsContactId: 87_654,
        userLogin: "System Tester",
      },
    }.to_json
  end
end
