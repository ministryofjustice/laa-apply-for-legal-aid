require "rails_helper"

ModelStruct = Struct.new(:happened_on)
FormStruct = Struct.new(:happened_day, :happened_month, :happened_year)
SuffixedFormStruct = Struct.new(:happened_3i, :happened_2i, :happened_1i)

RSpec.describe DateFieldBuilder do
  subject(:date_field_builder) do
    described_class.new(
      form:,
      model:,
      method: :happened_on,
      prefix: :happened_,
      suffix:,
    )
  end

  let(:form_date) { Time.zone.today }
  let(:model_date) { 2.days.ago }
  let(:model) { ModelStruct.new(model_date) }
  let(:form) { FormStruct.new(form_date.day, form_date.month, form_date.year) }
  let(:suffix) { nil }

  describe "#fields" do
    it "returns three prefixed names for day, month, and year" do
      expect(date_field_builder.fields).to eq(%i[happened_year happened_month happened_day])
    end
  end

  describe "#from_form" do
    it "returns array of data stored in form prefixed part fields" do
      expect(date_field_builder.from_form).to eq([form_date.year, form_date.month, form_date.day])
    end
  end

  describe "#model_attributes" do
    it "returns hash of data for form build from model date" do
      expected = {
        happened_day: model_date.day,
        happened_month: model_date.month,
        happened_year: model_date.year,
      }
      expect(date_field_builder.model_attributes).to eq(expected)
    end
  end

  describe "#model_date" do
    it "returns date from model" do
      expect(date_field_builder.model_date).to eq(model_date)
    end
  end

  describe "#form_date" do
    it "returns date built from form part fields" do
      expect(date_field_builder.form_date).to eq(form_date)
    end

    context "with two character year" do
      let(:form) { FormStruct.new(form_date.day, form_date.month, form_date.strftime("%y")) }

      it "returns date built from form part fields" do
        expect(date_field_builder.form_date).to eq(form_date)
      end
    end
  end

  describe "#form_date_invalid?" do
    it "returns false with valid date data" do
      expect(date_field_builder.form_date_invalid?).to be false
    end

    context "with invalid data" do
      let(:form) { FormStruct.new(form_date.day, 15, form_date.year) }

      it "returns false" do
        expect(date_field_builder.form_date_invalid?).to be true
      end
    end

    context "with two character year" do
      let(:form) { FormStruct.new(form_date.day, form_date.month, form_date.strftime("%y")) }

      it "returns false with valid date data" do
        expect(date_field_builder.form_date_invalid?).to be false
      end
    end

    context "with one character year" do
      let(:form) { FormStruct.new(form_date.day, form_date.month, form_date.strftime("%y").last) }

      it "returns true" do
        expect(date_field_builder.form_date_invalid?).to be true
      end
    end
  end

  describe "#blank?" do
    it "returns false if fully populated" do
      expect(date_field_builder.blank?).to be false
    end

    context "when all form part fields are empty" do
      let(:form) { FormStruct.new }

      it "returns true" do
        expect(date_field_builder.blank?).to be true
      end
    end
  end

  describe "#partially_complete?" do
    it "returns false if fully populated" do
      expect(date_field_builder.partially_complete?).to be false
    end

    context "when one part field is empty" do
      let(:form) { FormStruct.new(form_date.day, nil, form_date.year) }

      it "returns true" do
        expect(date_field_builder.partially_complete?).to be true
      end
    end

    context "when all part fields empty" do
      let(:form) { FormStruct.new }

      it "returns false" do
        expect(date_field_builder.partially_complete?).to be false
      end
    end
  end

  context "when a suffix is set" do
    let(:suffix) { :gov_uk }
    let(:form) { SuffixedFormStruct.new(form_date.day, form_date.month, form_date.strftime("%y")) }

    it "returns date built from form new style part fields" do
      expect(date_field_builder.form_date).to eq(form_date)
    end
  end
end
