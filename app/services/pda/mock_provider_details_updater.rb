require "webmock"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")

module PDA
  class MockProviderDetailsUpdater < ProviderDetailsUpdater
    include WebMock::API

    def initialize(provider, office_code)
      WebMock.enable!
      WebMock.allow_net_connect!
      load_stubs

      super
    end

  private

    def load_stubs
      stub_office_schedules_for_0x395u
      stub_provider_user_for("51cdbbb4-75d2-48d0-aaac-fa67f013c50a")
      stub_office_schedules_not_found_for("2N078D")
      stub_office_schedules_not_found_for("A123456")
    end
  end
end
