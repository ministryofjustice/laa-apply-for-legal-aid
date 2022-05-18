# before and after hooks for feature tests
#
Before("@hmrc_use_dev_mock") do
  allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_return(true)
end

After("@hmrc_use_dev_mock") do
  allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_call_original
end
