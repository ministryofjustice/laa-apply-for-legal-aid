class CyHelper
  FILES_TO_TRANSLATE = %w[
    accessibility_statement
    activemodel
    activerecord
    citizens
    contacts
    currency
    dates
    errors
    feedback
    generic
    helpers
    layouts
    model_enum_translations
    privacy_policy
    shared
    transaction_types
    true_layer_errors
  ].freeze

  def initialize
    @cy_dir = Rails.root.join('config/locales/cy')
    @en_dir = Rails.root.join('config/locales/en')
  end

  def run
    copy_en_to_cy
    translation_files.each { |f| reverse_strings(f) }
  end

  private

  def copy_en_to_cy
    Rails.logger.info 'copying en locale to cy'
    en_files = FILES_TO_TRANSLATE.map { |f| Rails.root.join("config/locales/en/#{f}.yml").to_s }
    FileUtils.mkdir @cy_dir unless File.exist?(@cy_dir)
    FileUtils.cp en_files, @cy_dir, verbose: true
  end

  def translation_files
    Dir["#{@cy_dir}/*.yml"].sort
  end

  def reverse_strings(filename)
    Rails.logger.info "Reversing #{filename}"
    hash = YAML.load_file(filename)
    hash['cy'] = hash['en']
    hash.delete('en')
    hash['cy'].each_key { |k| reverse_key(k, hash['cy']) }
    File.open(filename, 'w') { |f| f.puts(YAML.dump(hash)) }
  end

  def reverse_key(key, hash)
    case hash[key]
    when String then hash[key] = reverse_but_preserve_tokens(hash[key])
    when Hash then hash[key].each_key do |k|
                     reverse_key(k, hash[key])
                   end
    end
  end

  def reverse_but_preserve_tokens(string)
    reversed_string = string.reverse
    reversed_string.gsub(/\}(\S+)\{%/, &:reverse)
  end
end
