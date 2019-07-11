# the legal legal_framework data needs to be seeded in a specific order to
# preserve referential integrity - proceeding_type_scope_limitations must be
# seeded after proceeding_types and scope_limitations. this order is defined in
# the array below

legal_framework_filepath = 'db/seeds/legal_framework/'.freeze

legal_framework_seeds = ['proceeding_types.rb',
                         'scope_limitations.rb',
                         'proceeding_type_scope_limitations.rb'].freeze

legal_framework_seeds.each do |seed|
  seed_file = Rails.root.join(legal_framework_filepath, seed)
  message = "Seeding '#{seed_file}'..."
  Rails.logger.info message
  puts message
  load seed_file
end
