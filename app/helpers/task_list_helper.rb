module TaskListHelper
  def task_list_item(name:, status:, url: nil)
    tag_class = status == 'Completed' ? nil : 'govuk-tag--grey'
    render(
      'providers/merits_task_lists/task_list_item',
      name: name,
      status: status,
      url: url,
      tag_class: tag_class
    )
  end
end
