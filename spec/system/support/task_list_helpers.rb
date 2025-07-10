module TaskListHelpers
  def section_list_for(text)
    heading = page.find("h2.govuk-task-list__section", text:)
    heading.ancestor("li")
  end

  def expect_section_with_task_list_items(section_title, rows = nil)
    rows ||= yield

    raise "Invalid row keys for helper #{__method__}" unless rows.flat_map(&:keys).uniq.all? { |k| %i[name link_enabled status].include?(k) }

    within(section_list_for(section_title)) do
      rows.each do |row|
        expect(page).to have_css(".govuk-task-list__name-and-hint", text: row[:name])
        expect(page).to have_link(row[:name]) if row[:link_enabled] == true
        expect(page).to have_no_link(row[:name]) if row[:link_enabled] == false
        expect(page).to have_css(".govuk-task-list__status", text: row[:status])
      end
    end
  end
end
