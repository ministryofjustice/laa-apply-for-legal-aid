module TaskListHelper
  def task_list_item(name:, status:)
    tag_class = status == 'completed' ? nil : 'govuk-tag--grey'
    render(
      'providers/merits_task_lists/task_list_item',
      name: name,
      status: status,
      url: _task_url(name),
      tag_class: tag_class
    )
  end

  private

  def _task_url(name)
    url_fragment = I18n.t("providers.merits_task_lists.task_list_item.urls.#{name}")
    "providers_legal_aid_application_#{url_fragment}".to_sym
  end
end
