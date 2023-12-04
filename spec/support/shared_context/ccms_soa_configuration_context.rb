RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "with ccms soa configuration", shared_context: :metadata do
  before do
    ccms_struct = Struct.new(:client_username, :client_password_type, :client_password, :user_login, :user_role)
    test_config = ccms_struct.new(
      client_username: "my_soap_client_username",
      client_password_type: "password_type",
      client_password: "xxxxx",
      user_login: "my_login",
      user_role: "my_role",
    )
    allow(Rails.configuration.x).to receive(:ccms_soa).and_return(test_config)
  end
end
