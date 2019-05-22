class YamlStore
  KeyNotRecognisedError = Class.new(StandardError)
  ConfigurationError = Class.new(StandardError)

  class << self
    attr_reader :yaml_file_path, :yaml_args

    def use_yml_file(path, *args)
      @yaml_file_path = path
      @yaml_args = args
    end

    def from_yaml_file(path, section: nil)
      hash = YAML.load_file(path)
      data = section ? hash[section.to_s] : hash
      new(data)
    end

    def store
      raise ConfigurationError, "use_yml_file not set in #{name}" unless yaml_file_path.present?

      @store ||= from_yaml_file(yaml_file_path, *yaml_args)
    end
    delegate :threshold, to: :store
  end

  attr_reader :data

  def initialize(hash)
    @data = hash.deep_symbolize_keys
  end

  def threshold(key)
    data[key] || raise(KeyNotRecognisedError, "key '#{key}' not set")
  end
end
