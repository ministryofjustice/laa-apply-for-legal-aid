When("I enter a date of birth that will make me 16 today") do
  dob = 16.years.ago
  fill_in("applicant_date_of_birth_3i", with: dob.day)
  fill_in("applicant_date_of_birth_2i", with: dob.month)
  fill_in("applicant_date_of_birth_1i", with: dob.year)
end

When("I enter a date of birth that will make me 18 tomorrow") do
  dob = (18.years - 1.day).ago
  fill_in("applicant_date_of_birth_3i", with: dob.day)
  fill_in("applicant_date_of_birth_2i", with: dob.month)
  fill_in("applicant_date_of_birth_1i", with: dob.year)
end

When("I enter a date of birth that will make me 18 today") do
  dob = if Time.zone.today.month == 2 && Time.zone.today.day == 29
          18.years.ago + 1.day
        else
          18.years.ago
        end
  fill_in("applicant_date_of_birth_3i", with: dob.day)
  fill_in("applicant_date_of_birth_2i", with: dob.month)
  fill_in("applicant_date_of_birth_1i", with: dob.year)
end
