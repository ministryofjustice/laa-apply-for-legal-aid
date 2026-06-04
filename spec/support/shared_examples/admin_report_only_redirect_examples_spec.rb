RSpec.shared_examples "an admin with digest only privileges" do
  it "redirects to the reports page" do
    expect(response).to have_http_status(:redirect)
    follow_redirect!
    expect(response.body).to include("Admin reports and downloads")
  end
end
