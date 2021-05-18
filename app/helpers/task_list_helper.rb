module TaskListHelper
  def task_list_item(name:, status:, legal_aid_application: nil, ccms_code: nil)
    tag_class = status == :complete ? nil : 'govuk-tag--grey'
    render(
      'providers/merits_task_lists/task_list_item',
      name: name,
      status: status,
      url: ccms_code ? proceeding_task_url(name, legal_aid_application, ccms_code) : _task_url(name, legal_aid_application),
      proceeding_merits_task: ccms_code.present?,
      tag_class: tag_class
    )
  end

  private

  def _task_url(name, legal_aid_application)
    prefix = _task_prefix(name, legal_aid_application)
    "#{prefix}providers_legal_aid_application_#{url_fragment(name)}".to_sym
  end

  def _task_prefix(name, legal_aid_application)
    return 'new_' if name.eql?(:children_application) && application_has_no_involved_children?(legal_aid_application)

    ''
  end

  def application_has_no_involved_children?(legal_aid_application)
    legal_aid_application.involved_children.empty?
  end

  def proceeding_task_url(name, application, ccms_code)
    url = "providers_merits_task_list_#{url_fragment(name)}_path".to_sym

    __send__(url, application_proceeding_type_id(application, ccms_code))
  end

  def url_fragment(name)
    I18n.t("providers.merits_task_lists.task_list_item.urls.#{name}")
  end

  def application_proceeding_type_id(application, ccms_code)
    return nil unless ccms_code && application

    apt = application.application_proceeding_types.find do |x|
      x.proceeding_type.ccms_code == ccms_code.to_s
    end

    apt.id
  end
end
