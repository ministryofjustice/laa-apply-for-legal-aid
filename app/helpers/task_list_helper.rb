module TaskListHelper
  def task_list_item(name:, status:, legal_aid_application: nil, ccms_code: nil)
    tag_class = status == :complete ? nil : 'govuk-tag--grey'
    render(
      'providers/merits_task_lists/task_list_item',
      name: name,
      status: status,
      url: ccms_code ? proceeding_task_url(name, legal_aid_application, ccms_code) : _task_url(name, legal_aid_application, status),
      proceeding_merits_task: ccms_code.present?,
      tag_class: tag_class
    )
  end

  private

  def _task_url(name, legal_aid_application, status)
    url = if application_has_no_involved_children?(legal_aid_application) && name.eql?(:children_application)
            "new_providers_legal_aid_application_#{url_fragment(name)}_path".to_sym
          else
            "providers_legal_aid_application_#{new_url_fragment(name, status, legal_aid_application)}_path".to_sym
          end
    __send__(url, legal_aid_application)
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

  def new_url_fragment(name, status, application)
    name = 'has_other_involved_children' if name.eql?(:children_application) && (status.eql?(:complete) || application.involved_children.any?)
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
