namespace :cucumber do
  desc 'List all defined steps'
  task :steps do
    require 'hirb'
    extend Hirb::Console
    puts "CUCUMBER steps:"
    puts ""
    step_definition_dir = "features/step_definitions"

    results = []
    Dir.glob(File.join(step_definition_dir,'**/*.rb')).each do |step_file|
      File.new(step_file).read.each_line.each_with_index do |line, number|
        next unless line =~ /^\s*(Given|When|Then)\((.+)\)\s*do$/
        name = $2.gsub('/', '').gsub('^', '').gsub('$', '').gsub("'", '').gsub('"', '')
        results<< OpenStruct.new(stepname: name, location: "#{step_file}:#{number + 1}")
      end
    end

    table results, :resize => false, :fields=>[:stepname, :location]
    puts ""
  end

end
