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

# TODO: can we get rid of this or replace for silas mocking (AP-6185)
Rails.configuration.x.lassie.mock_auth = ValidTestUsersStruct.new(
  users: [
    TestCredentialsStruct.new("test1", "test1@example.com"),
    TestCredentialsStruct.new("will-c", "william.clarke@justice.gov.uk"),
    TestCredentialsStruct.new("test-sch", "apply-for-civil-legal-aid@justice.gov.uk"),
    TestCredentialsStruct.new("test2", "test2@example.com"),
    TestCredentialsStruct.new("test3", "really-really-long-email-address@example.com"),
    TestCredentialsStruct.new("firm1-user1", "firm1-user1@example.com"),
    TestCredentialsStruct.new("firm1-user2", "firm1-user2@example.com"),
    TestCredentialsStruct.new("firm2-user1", "firm2-user1@example.com"),
    TestCredentialsStruct.new("NEETADESOR", "neeta@example.com"),
    TestCredentialsStruct.new("MARTIN.RONAN@DAVIDGRAY.CO.UK", "martin.ronan@example.com"),
    TestCredentialsStruct.new("HFITZSIMONS@EDWARDHAYES.CO.UK", "hfitzsimons@example.com"),
    TestCredentialsStruct.new("ahernk", "katharine.ahern@justice.gov.uk"),
    TestCredentialsStruct.new("rose", "rose.azadkhan@justice.gov.uk"),
    TestCredentialsStruct.new("mkeen", "mike.keen@justice.gov.uk"),
  ],
  password: "password",
)
