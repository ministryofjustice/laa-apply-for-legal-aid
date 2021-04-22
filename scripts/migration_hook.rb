#!/usr/bin/env ruby
require_relative '../db/anonymise/rules'

def tables_in_schema
  f = IO.read('db/schema.rb')
  f.each_line.filter_map { |line| line.match(/create_table "(\w*)"/)[1] if line[/create_table/] }
end

def tables_in_rules
  @rules.keys.map(&:to_s)
end

puts "tables in schema: #{tables_in_schema.count}"
puts "tables with rules: #{tables_in_rules.count}"

def rules_without_tables
  tables_in_rules - tables_in_schema
end

def tables_without_rules
  tables_in_schema - tables_in_rules
end

exit_status = 0

if rules_without_tables.any?
  puts "Rules exist for non-existent tables: #{rules_without_tables.join(', ')}"
  exit_status = 1
end

if tables_without_rules.any?
  puts "Tables missing rules: #{tables_without_rules.join(', ')}"
  puts 'You can find rules at db/anonymise/rules.rb'
  exit_status = 1
end

exit exit_status
