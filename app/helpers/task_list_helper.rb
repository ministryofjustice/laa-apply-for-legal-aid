module TaskListHelper
  def task_list_item(name:, status:, ccms_code: nil)
    tag_class = status == 'completed' ? nil : 'govuk-tag--grey'
    render(
      'providers/merits_task_lists/task_list_item',
      name: name,
      status: status,
      url: ccms_code ? proceeding_task_url(name, ccms_code) : _task_url(name),
      proceeding_merits_task: ccms_code.present?,
      tag_class: tag_class
    )
  end

  private

  def _task_url(name)
    "providers_legal_aid_application_#{url_fragment(name)}".to_sym
  end

  def proceeding_task_url(name, ccms_code)
    url = "providers_merits_task_list_#{url_fragment(name)}_path".to_sym

    __send__(url, application_proceeding_type_id(ccms_code))
  end

  def url_fragment(name)
    I18n.t("providers.merits_task_lists.task_list_item.urls.#{name}")
  end

  def application_proceeding_type_id(ccms_code)
    return nil unless ccms_code

    pt = ProceedingType.where(ccms_code: ccms_code).first
    pt.application_proceeding_types.first.id
  end
end
