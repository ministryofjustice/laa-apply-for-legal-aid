RSpec.shared_examples 'a provider not authenticated' do
  it 'should redirect the user to the login page' do
    expect(response).to redirect_to(new_provider_session_path)
  end
end
