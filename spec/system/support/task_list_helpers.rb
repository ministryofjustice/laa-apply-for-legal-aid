module TaskListHelpers
  def section_list_for(text)
    heading = page.find("h2.govuk-task-list__section", text:)
    heading.ancestor("li")
  end
end
