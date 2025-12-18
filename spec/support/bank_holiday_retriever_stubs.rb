require Rails.root.join("spec/fixtures/stub_data/bank_holidays_fixture")

def stub_bankholiday_success
  stub_request(:get, %r{#{Rails.configuration.x.bank_holidays_url}})
    .to_return(
      status: 200,
      body: BankHolidaysFixture.data.to_json,
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    )
end

def stub_bankholiday_not_found
  stub_request(:get, %r{#{Rails.configuration.x.bank_holidays_url}})
    .to_return(
      status: 404,
      body: "",
      headers: { "Content-Type" => "text/html; charset=utf-8" },
    )
end

def stub_bankholiday_unprocessable
  stub_request(:get, %r{#{Rails.configuration.x.bank_holidays_url}})
    .to_return(
      status: 422,
      body: "",
      headers: { "Content-Type" => "text/html; charset=utf-8" },
    )
end
