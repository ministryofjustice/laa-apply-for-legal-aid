# the legal legal_framework data needs to be seeded in a specific order to
# preserve referential integrity - this order is defined in the array below

legal_framework_filepath = 'db/seeds/legal_framework/'.freeze

legal_framework_seeds = ['levels_of_service.rb',
                         'proceeding_types.rb',
                         'scope_limitations.rb',
                         'proceeding_type_scope_limitations.rb'].freeze

legal_framework_seeds.each do |seed|
  seed_file = Rails.root.join(legal_framework_filepath, seed)
  load seed_file
end
