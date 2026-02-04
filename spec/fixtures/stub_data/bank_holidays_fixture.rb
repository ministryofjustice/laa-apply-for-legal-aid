module BankHolidaysFixture
  def self.data
    {
      "england-and-wales" => {
        "division" => "england-and-wales",
        "events" => [
          { "title" => "Christmas Day", "date" => "2025-12-25", "notes" => "", "bunting" => true },
          { "title" => "Boxing Day", "date" => "2025-12-26", "notes" => "", "bunting" => true },
          { "title" => "New Year's Day", "date" => "2026-01-01", "notes" => "", "bunting" => true },
        ],
      },
    }
  end

  def self.legacy_data
    # this removes the need for vcr and older cassettes where dates had been
    # locked in 2020/2021
    {
      "england-and-wales" => {
        "division" => "england-and-wales",
        "events" => [
          { "title" => "Christmas Day", "date" => "2020-12-25", "notes" => "", "bunting" => true },
          { "title" => "Boxing Day", "date" => "2020-12-28", "notes" => "Substitute day", "bunting" => true },
          { "title" => "New Year’s Day", "date" => "2021-01-01", "notes" => "", "bunting" => true },
          { "title" => "Good Friday", "date" => "2021-04-02", "notes" => "", "bunting" => false },
          { "title" => "Easter Monday", "date" => "2021-04-05", "notes" => "", "bunting" => true },
          { "title" => "Spring bank holiday", "date" => "2021-05-31", "notes" => "", "bunting" => true },
        ],
      },
    }
  end
end
