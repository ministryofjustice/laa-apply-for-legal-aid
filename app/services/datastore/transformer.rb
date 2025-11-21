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
      @hash.deep_transform_keys { |k| k.to_s.camelize(:lower).to_sym }
    end
  end
end
