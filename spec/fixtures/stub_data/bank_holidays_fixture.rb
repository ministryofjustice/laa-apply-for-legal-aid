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
end
