module Providers
  module LinkApplication
    class MakeLinkForm < BaseForm
      form_for LinkedApplication

      attr_accessor :link_type_code
    end
  end
end
