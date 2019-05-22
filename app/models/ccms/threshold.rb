module CCMS
  class Threshold < YamlStore
    use_yml_file Rails.root.join('config/ccms/thresholds.yml'), section: :ccms
  end
end
