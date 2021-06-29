require 'rails_helper'
require "#{Rails.root}/lib/tasks/helpers/ccms_payload_parser"

RSpec.describe CCMSPayloadParser do
  it 'parses' do
    parser = described_class.new.run
  end
end
