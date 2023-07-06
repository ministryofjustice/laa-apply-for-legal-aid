class Partner < ApplicationRecord
  belongs_to :legal_aid_application, dependent: :destroy
  has_many :hmrc_responses, class_name: "HMRC::Response", as: :owner
  has_many :employments, as: :owner
end
