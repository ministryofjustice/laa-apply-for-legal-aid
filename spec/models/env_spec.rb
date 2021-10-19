require 'rails_helper'

RSpec.describe 'Env' do
  it 'does' do
    puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
    pp ENV['APPLICATION_DEPLOY_NAME']
  end
end
