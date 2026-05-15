require "rails_helper"
RSpec.describe BaseJsonBuilder do
  let(:dummy_model_klass) do
    Class.new do
      def some_decimal
        BigDecimal("123.45")
      end
    end
  end

  let(:dummy_nested_model_klass) do
    Class.new do
      def some_nested_decimal
        BigDecimal("543.21")
      end
    end
  end

  describe ".build" do
    context "when given a non-nil object" do
      let(:object) { instance_double(dummy_model_klass) }

      it "returns an instance of the builder" do
        builder = described_class.build(object)
        expect(builder).to be_a(described_class)
        expect(builder.object).to eq(object)
      end
    end

    context "when given a nil object" do
      it "returns nil" do
        expect(described_class.build(nil)).to be_nil
      end
    end
  end

  describe "#attribute_hash" do
    it "raises NotImplementedError" do
      builder = described_class.new(dummy_model_klass.new)
      expect { builder.attribute_hash }.to raise_error(NotImplementedError)
    end
  end

  describe "#as_json" do
    let(:dummy_builder_class) do
      nested_builder_class = dummy_nested_builder_class
      nested_model_klass = dummy_nested_model_klass

      # NOTE: We use define_method here to avoid eager evaluation of the nested builder and model classes before they are defined
      Class.new(BaseJsonBuilder) do
        define_method(:attribute_hash) do
          {
            some_decimal:,
            some_nested_builder: nested_builder_class.new(nested_model_klass.new),
          }
        end
      end
    end

    let(:dummy_nested_builder_class) do
      Class.new(BaseJsonBuilder) do
        def attribute_hash
          { some_nested_decimal: }
        end
      end
    end

    let(:builder) { dummy_builder_class.new(dummy_model_klass.new) }

    it "normalizes decimals as strings" do
      payload = builder.as_json.to_json

      expect(payload).to eql("{\"some_decimal\":\"123.45\",\"some_nested_builder\":{\"some_nested_decimal\":\"543.21\"}}")
    end
  end
end
