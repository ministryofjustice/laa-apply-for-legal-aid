require "rails_helper"

RSpec.describe TaskStatus::ValueObject do
  subject(:object) { described_class.new }

  it "defines getter and setter methods for each status" do
    expect(object)
      .to respond_to(
        :cannot_start!,
        :cannot_start?,
        :not_ready!,
        :not_ready?,
        :not_started!,
        :not_started?,
        :in_progress!,
        :in_progress?,
        :review!,
        :review?,
        :completed!,
        :completed?,
        :unknown!,
        :unknown?,
      )
  end

  it "responds to expected methods" do
    expect(object).to respond_to(:value, :value=, :colour)
  end

  it "defaults to unknown status" do
    expect(object).to be_unknown
  end

  describe "#colour" do
    it "returns css tag classes associated with the status" do
      expect(object.colour).to be_nil

      object.cannot_start!
      expect(object.colour).to be_nil

      object.not_ready!
      expect(object.colour).to eql "grey"

      object.not_started!
      expect(object.colour).to eql "blue"

      object.in_progress!
      expect(object.colour).to eql "light-blue"

      object.review!
      expect(object.colour).to eql "yellow"

      object.completed!
      expect(object.colour).to be_nil
    end
  end

  describe "#valid?" do
    it "returns false when current status is a valid option" do
      object.value = :completed
      expect(object).to be_valid
    end

    it "returns false when current status is not a valid option" do
      object.value = :foobar
      expect(object).not_to be_valid
    end
  end

  describe "#enabled?" do
    it "returns false when cannot_start" do
      object.cannot_start!
      expect(object).not_to be_enabled
    end

    it "returns false when not_ready" do
      object.not_ready!
      expect(object).not_to be_enabled
    end

    it "returns true when not_started" do
      object.not_started!
      expect(object).to be_enabled
    end

    it "returns true when in_progress" do
      object.in_progress!
      expect(object).to be_enabled
    end

    it "returns true when review" do
      object.review!
      expect(object).to be_enabled
    end

    # This will change when we unlock
    it "returns false when completed" do
      object.completed!
      expect(object).not_to be_enabled
    end

    it "returns false when unknown" do
      object.unknown!
      expect(object).not_to be_enabled
    end
  end

  describe "#current_status" do
    it "returns a data object matching its own status value" do
      object.not_started!
      expect(object.current_status).to have_attributes(value: :not_started, colour: "blue")
    end

    it "returns nil when value is not valid" do
      object.value = :foobar
      expect(object.current_status).to be_nil
    end
  end
end
