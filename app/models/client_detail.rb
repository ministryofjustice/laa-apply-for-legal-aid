require 'date'

class ClientDetail < ApplicationRecord

  validates :name, :date_of_birth, presence: true

  validate :validate_date_of_birth

  private

  def validate_date_of_birth
    if date_of_birth.present? && (date_of_birth < "01/01/1900".to_date || date_of_birth > Date.today)
       errors.add(:date_of_birth, "Date of birth is not valid")
    end
  end
end
