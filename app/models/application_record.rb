class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  self.ignored_columns += %w[declaration_accepted_at]
end
