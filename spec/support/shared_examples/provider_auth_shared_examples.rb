RSpec.shared_examples "a provider not authenticated" do
  it "redirects the user to the login page" do
    expect(response).to redirect_to(new_provider_session_path)
  end
end

RSpec.shared_examples "an authenticated provider from a different firm" do
  it "redirects the user to the access denied page" do
    expect(response).to redirect_to(error_path(:access_denied))
  end
end
