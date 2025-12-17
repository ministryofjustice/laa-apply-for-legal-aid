require "rails_helper"

RSpec.describe TimeHelper do
  describe "number_of_days_ago" do
    let(:days) { 2 }

    before do
      new_time = Time.zone.local(2020, 10, 1, 1, 0, 0)
      travel_to(new_time)
    end

    it "returns a valid date" do
      expect(helper.number_of_days_ago(days)).to eq "29  9 2020"
    end
  end

  describe "gds_human_time" do
    it "does not display zero minutes" do
      expect(helper.gds_human_time(Time.zone.local(2020, 10, 1, 7, 0, 0))).to eq "7am"
    end

    it "does display non-zero minutes" do
      expect(helper.gds_human_time(Time.zone.local(2020, 10, 1, 21, 30, 0))).to eq "9:30pm"
    end
  end
end
