# Prevents error messages in sidekiq in dev boxes.
# should be removed once sidekiq uses #exists?
#
# TODO remove when sidekiq updated
Redis.exists_returns_integer = false
