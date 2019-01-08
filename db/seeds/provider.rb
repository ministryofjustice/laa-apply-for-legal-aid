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
  Provider.create(user_data)
end
