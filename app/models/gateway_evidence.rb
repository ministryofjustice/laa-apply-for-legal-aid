class GatewayEvidence < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: "Provider", optional: true
end
