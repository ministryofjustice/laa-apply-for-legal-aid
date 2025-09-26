require Rails.root.join("spec/services/pda/provider_details_request_stubs")
module LoginHelpers
  def login_as_a_provider
    @registered_provider = create(:provider, silas_id: "51cdbbb4-75d2-48d0-aaac-fa67f013c50a")
    @registered_provider.office_codes = "0X395U:2N078D:A123456"

    stub_office_schedules_for_0x395u

    allow(ProviderContractDetailsWorker)
      .to receive(:perform_async).and_return(true)

    login_as @registered_provider
  end
end
