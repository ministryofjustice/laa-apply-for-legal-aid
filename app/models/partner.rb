class Partner < ApplicationRecord
  belongs_to :legal_aid_application, dependent: :destroy
  has_many :hmrc_responses, class_name: "HMRC::Response", as: :owner
  has_many :employments, as: :owner

  def json_for_hmrc
    {
      first_name:,
      last_name:,
      dob: date_of_birth,
      nino: national_insurance_number,
    }
  end
end
