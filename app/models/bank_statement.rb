class BankStatement < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: "Provider", optional: true
  belongs_to :attachment, optional: true
end
