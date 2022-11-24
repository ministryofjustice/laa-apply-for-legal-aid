class AgeCalculator
  def self.call(date_of_birth, as_of)
    age = as_of.year - date_of_birth.year
    date_of_birth > as_of.years_ago(age) ? age - 1 : age
  end
end
