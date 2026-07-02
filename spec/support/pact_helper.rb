require "pact"
require "pact/rspec"

RSpec.shared_context "with legal framework api consumer pact" do
  has_http_pact_between "laa-apply-for-legal-aid", "legal-framework-api", opts: { pact_dir: "spec/pacts" }
end
