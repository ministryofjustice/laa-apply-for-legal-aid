Then('the application should be auto granted in CCMS') do
  expect(CCMS::ManualReviewDeterminer.new(@legal_aid_application).manual_review_required?).to be false
end

Then('the application must be manually reviewed in CCMS') do
  expect(CCMS::ManualReviewDeterminer.new(@legal_aid_application).manual_review_required?).to be true
end
