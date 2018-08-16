class ClientDetail < ApplicationRecord

  validates :name,  presence: true

  validates :dob_day, numericality: {
                    greater_than_or_equal_to: 1, less_than_or_equal_to: 31,
                  }
  validates :dob_month, numericality: {
                    greater_than_or_equal_to: 1, less_than_or_equal_to: 12,
                   }
   validates :dob_year, numericality: {
                    greater_than_or_equal_to: 1900, less_than_or_equal_to: 2099,
                  }

end
