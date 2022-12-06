# frozen_string_literal: true

class ValidTestUsersStruct
  attr_reader :users, :password

  def initialize(users:, password:)
    @users = users
    @password = password
  end

  # imitate OpenStruct's behaviour of returning nil for unrecognised methods
  def method_missing(_meth)
    nil
  end

  def respond_to_missing?(_meth)
    true
  end
end

TestCredentialsStruct = Struct.new(:username, :email)

Rails.configuration.x.application.mock_saml = ValidTestUsersStruct.new(
  users: [
    TestCredentialsStruct.new("test1", "test1@example.com"),
    TestCredentialsStruct.new("will-c", "william.clarke@digital.justice.gov.uk"),
    TestCredentialsStruct.new("test-sch", "apply-for-civil-legal-aid@digital.justice.gov.uk"),
    TestCredentialsStruct.new("test2", "test2@example.com"),
    TestCredentialsStruct.new("test3", "really-really-long-email-address@example.com"),
    TestCredentialsStruct.new("firm1-user1", "firm1-user1@example.com"),
    TestCredentialsStruct.new("firm1-user2", "firm1-user2@example.com"),
    TestCredentialsStruct.new("firm2-user1", "firm2-user1@example.com"),
    TestCredentialsStruct.new("NEETADESOR", "neeta@example.com"),
    TestCredentialsStruct.new("MARTIN.RONAN@DAVIDGRAY.CO.UK", "martin.ronan@example.com"),
    TestCredentialsStruct.new("HFITZSIMONS@EDWARDHAYES.CO.UK", "hfitzsimons@example.com"),
    TestCredentialsStruct.new("sr", "stephen.richards@digital.justice.gov.uk"),
    TestCredentialsStruct.new("ahernk", "katharine.ahern@digital.justice.gov.uk"),
    TestCredentialsStruct.new("cm", "connor.mcquillan@digital.justice.gov.uk"),
    TestCredentialsStruct.new("jsugarman", "joel.sugarman@digital.justice.gov.uk"),
    TestCredentialsStruct.new("rose", "rose.azadkhan@digital.justice.gov.uk"),
  ],
  password: "password",
)
