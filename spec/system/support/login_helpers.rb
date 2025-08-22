require Rails.root.join("spec/services/pda/provider_details_request_stubs")
module LoginHelpers
  def login_as_a_provider
    @registered_provider = create(:provider, silas_id: "c680f03d-48ed-4079-b3c9-ca0c97d9279d")
    @registered_provider.office_codes = "0X395U:2N078D:A123456"

    stub_office_schedules_for_0x395u

    stub_request(:get, "#{Rails.configuration.x.pda.url}/ccms-provider-users/#{@registered_provider.silas_id}")
      .to_return(body: provider_user_body, status: 200)

    allow(ProviderContractDetailsWorker)
      .to receive(:perform_async).and_return(true)

    login_as @registered_provider
  end

private

  def provider_user_body
    {
      userUuid: "c680f03d-48ed-4079-b3c9-ca0c97d9279d",
      userLogin: "System Tester",
      ccmsContactId: 87_654,
    }.to_json
  end
end
