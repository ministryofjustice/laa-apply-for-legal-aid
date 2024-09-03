Then("the \"Client details\" check your answers section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#client-details-questions", expected: table)
end

Then("the \"Client details\" check your answers section should not contain:") do |table|
  expect_questions_in(selector: "#client-details-questions", expected: table, negate: true)
end
