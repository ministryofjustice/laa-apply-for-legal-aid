module UploadedEvidence
  class ListService < Base
    def call
      attachment_type_options
      self
    end
  end
end
