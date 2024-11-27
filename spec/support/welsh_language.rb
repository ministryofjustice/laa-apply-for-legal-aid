RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:use_welsh_locale] == true
      I18n.with_locale(:cy) { example.run }
    else
      example.run
    end
  end
end
