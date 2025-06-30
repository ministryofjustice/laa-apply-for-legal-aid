module LoginHelpers
  def login_as_a_provider
    @registered_provider = create(:provider, username: "System Tester")
    login_as @registered_provider
    firm = @registered_provider.firm
    @registered_provider.offices << create(:office, firm:, code: "London")
    @registered_provider.offices << create(:office, firm:, code: "Manchester")
  end
end
