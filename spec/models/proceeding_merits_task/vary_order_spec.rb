require "rails_helper"

RSpec.describe ProceedingMeritsTask::VaryOrder do
  it { is_expected.to belong_to :proceeding }
end
