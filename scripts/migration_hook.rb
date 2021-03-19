#!/usr/bin/env ruby
require_relative '../db/anonymise/rules'

def tables_in_schema
  f = IO.read('db/schema.rb')
  f.each_line.map { |line| line.match(/create_table "(\w*)"/)[1] if line[/create_table/] }.compact
end

def tables_in_rules
  @rules.keys
end

puts "tables in schema: #{tables_in_schema.count}"
puts "tables with rules: #{tables_in_rules.count}"

exit_status = 0
if tables_in_rules.count > tables_in_schema.count
  diff = tables_in_rules.reject { |x| tables_in_schema.include?(x.to_s) }
  puts "Rules exist for non-existent tables: #{diff.join(', ')}"
  exit_status = 1
elsif tables_in_schema.count > tables_in_rules.count
  diff = tables_in_schema.reject { |x| tables_in_rules.include?(x.to_sym) }
  puts "Tables missing from rules: #{diff.join(', ')}"
  exit_status = 1
end

exit exit_status
