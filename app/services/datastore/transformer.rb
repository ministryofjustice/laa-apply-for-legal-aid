# Simple utility class to transform hashes
# from an idiomatic ruby format to an idiomatic
# java format.
#
module Datastore
  class Transformer
    def initialize(hash)
      @hash = hash
    end

    def self.call(hash)
      new(hash).call
    end

    def call
      @hash = @hash.deep_transform_keys { |k| k.to_s.camelize(:lower).to_sym }

      # this is temporary to test whether the API is reposing with 403 due to a modsec ruke related to characters, if so modsec rules of APIs need loosening
      # on one [public] environment at least so we can develop more quickly. Long term and in production and staging we should be
      # using an internal routing to the API [which may avoid ]
      @hash = @hash.deep_transform_values do |value|
        value.is_a?(String) ? value.tr(";", ",") : value
      end

      @hash
    end
  end
end
