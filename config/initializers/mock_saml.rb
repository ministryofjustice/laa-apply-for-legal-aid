# frozen_string_literal: true

Rails.configuration.x.application.mock_saml = OpenStruct.new(
  users: [
    OpenStruct.new(username: 'test1', email: 'test1@example.com'),
    OpenStruct.new(username: 'test2', email: 'test2@example.com'),
    OpenStruct.new(username: 'test3', email: 'really-really-long-email-address@example.com'),
    OpenStruct.new(username: 'firm1-user1', email: 'firm1-user1@example.com'),
    OpenStruct.new(username: 'firm1-user2', email: 'firm1-user2@example.com'),
    OpenStruct.new(username: 'firm2-user1', email: 'firm2-user1@example.com'),
    OpenStruct.new(username: 'NEETADESOR', email: 'neeta@example.com'),
    OpenStruct.new(username: 'DAVIDGRAYLLPTWO', email: 'dg@example.com')
  ],
  password: 'password'
)
