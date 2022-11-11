Then("the \"Client details\" check your answers section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#client-details-questions", expected: table)
end
