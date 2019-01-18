Rails.logger.info 'Populating users'
providers = [
  {
    username: 'test1@example.com',
    type: 'Provider'
  },
  {
    username: 'test2@example.com',
    type: 'Provider'
  }
]

providers.each do |user_data|
  Provider.find_or_create_by(user_data)
end
