class AgeCalculator
  def self.call(date_of_birth, date)
    age = date.year - date_of_birth.year
    date_of_birth > date.years_ago(age) ? age - 1 : age
  end
end
