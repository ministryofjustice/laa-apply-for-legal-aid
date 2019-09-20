class Myposter
  def call
    conn = Faraday.new(
      url: 'http://localhost:3004',
      headers: {'Content-Type' => 'application/json'}
    )

    response = conn.post do | request |
      request.url '/choices'
      request.headers['Content-Type'] = 'application/json'
      request.body = request_body
    end
  end

  def request_body
    { a: 22 }.to_json
  end
end

require 'rails_helper'

RSpec.describe Myposter do
  it 'mocks a response' do

    # VCR.configure do |c|
    #       c.ignore_hosts 'localhost:3004'
    # end

    stub_request(:post, "http://localhost:3004/choices")
        .with(body: { a: 22}.to_json)
        .to_return(body: { success: true }.to_json)

    x = Myposter.new.call
    expect(x.body).to eq({ success: true }.to_json)
  end
end

