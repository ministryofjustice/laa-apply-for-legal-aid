RSpec::Matchers.define :message_contains do |text|
  match { |object| text.in?(object.message) }
end
