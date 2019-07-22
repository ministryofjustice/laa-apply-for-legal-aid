class Respondent < ApplicationRecord
  belongs_to :legal_aid_application

  def no_warning_letter_sent?
    !warning_letter_sent?
  end
end
