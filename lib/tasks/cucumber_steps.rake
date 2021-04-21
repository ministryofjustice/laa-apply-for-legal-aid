# rubocop:disable Rails/RakeEnvironment
namespace :cucumber do
  desc 'List all defined steps'
  task :steps do
    require 'hirb'
    extend Hirb::Console
    puts 'CUCUMBER steps:'
    puts ''
    step_definition_dir = 'features/step_definitions'

    results = []
    Dir.glob(File.join(step_definition_dir, '**/*.rb')).each do |step_file|
      File.new(step_file).read.each_line.each_with_index do |line, number|
        next unless line =~ /^\s*(Given|When|Then)\((.+)\)\s*do$/

        name = Regexp.last_match(2).delete('/').delete('^').delete('$').delete("'").delete('"')
        results << OpenStruct.new(stepname: name, location: "#{step_file}:#{number + 1}")
      end
    end

    table results, resize: false, fields: %i[stepname location]
    puts ''
  end
end
# rubocop:enable Rails/RakeEnvironment
