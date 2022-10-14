require "super_diff/rspec-rails"

# before and after hooks for feature tests
#
Before("@hmrc_use_dev_mock") do
  allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_return(true)
end

After("@hmrc_use_dev_mock") do
  allow(Rails.configuration.x).to receive(:hmrc_use_dev_mock).and_call_original
end

Before("not @clamav") do
  stdout = "/some/file/path.pdf: OK"
  stderr = ""
  status = instance_double(Process::Status, success?: true, exitstatus: 0)
  allow(Open3).to receive(:capture3).and_call_original
  allow(Open3)
    .to receive(:capture3)
    .with(/clamdscan/, any_args)
    .and_return([stdout, stderr, status])
end
