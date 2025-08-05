module LoginHelpers
  def login_as_a_provider
    allow(PDA::ProviderDetails).to receive(:call).and_return(true) # this stubs out calls to the pda schedules endpoint
    @registered_provider = create(:provider, username: "System Tester")
    login_as @registered_provider
    @registered_provider.office_codes = "0X395U:2N078D:A123456"
  end
end
