Then("the \"Second appeal\" check your answers section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#app-check-your-answers__second_appeal", expected: table)
end
