require 'rails_helper'

RSpec.describe 'Env' do
  it 'does' do
    puts ">>>>>>>>>>>> XLOG #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
    var = "LF69UUm#{ENV['APPLICATION_DEPLOY_NAME']}BH28"
    puts var
  end
end
