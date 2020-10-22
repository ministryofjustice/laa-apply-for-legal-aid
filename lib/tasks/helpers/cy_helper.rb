class CyHelper
  def initialize
    @cy_dir = Rails.root.join('config/locales/cy')
    @en_dir = Rails.root.join('config/locales/en')
  end

  def run
    initialize_cy_dir
    copy_en_to_cy
    translation_files.each { |f| reverse_strings(f) }
  end

  private

  def initialize_cy_dir
    delete_cy_dir if File.exist?(@cy_dir)
  end

  def delete_cy_dir
    puts 'deleting cy dir'
    system "rm -rf #{@cy_dir}"
  end

  def copy_en_to_cy
    puts 'copying en locale to cy'
    system "mkdir #{@cy_dir}"
    system "cp #{@en_dir}/* #{@cy_dir}/"
  end

  def translation_files
    Dir["#{@cy_dir}/*.yml"].sort
  end

  def reverse_strings(filename)
    puts "Reversing #{filename}"
    hash = YAML.load_file(filename)
    hash['cy'] = hash['en']
    hash.delete('en')
    hash['cy'].each_key { |k| reverse_key(k, hash['cy']) }
    File.open(filename, 'w') { |f| f.puts(YAML.dump(hash)) }
  end

  def reverse_key(key, hash)
    case hash[key]
    when String then hash[key] = hash[key].reverse
    when Hash then hash[key].each_key do |k|
                     reverse_key(k, hash[key])
                   end
    end
  end
end
