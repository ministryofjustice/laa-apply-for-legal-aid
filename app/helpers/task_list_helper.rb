module TaskListHelper
  def task_list_item(name:, status:, legal_aid_application: nil, ccms_code: nil)
    tag_colour = status == :complete ? nil : "grey"
    render(
      "providers/merits_task_lists/task_list_item",
      name:,
      status:,
      url: ccms_code ? proceeding_task_url(name, legal_aid_application, ccms_code) : _task_url(name, legal_aid_application, status),
      proceeding_merits_task: ccms_code.present?,
      tag_colour:,
      ccms_code:,
    )
  end

  def task_list_includes?(legal_aid_application, task_name)
    legal_aid_application.legal_framework_merits_task_list.serialized_data.match?(/name: :#{task_name}\n\s+dependencies: \*\d+/)
  end

private

  def _task_url(name, legal_aid_application, status)
    url = if display_new_page?(legal_aid_application, name)
            "new_providers_legal_aid_application_#{url_fragment(name)}_path".to_sym
          else
            "providers_legal_aid_application_#{new_url_fragment(name, status, legal_aid_application)}_path".to_sym
          end
    __send__(url, legal_aid_application)
  end

  def application_has_no_involved_children?(legal_aid_application)
    legal_aid_application.involved_children.empty?
  end

  def application_has_no_opponents?(legal_aid_application)
    legal_aid_application.opponents.empty?
  end

  def proceeding_task_url(name, application, ccms_code)
    url = "providers_merits_task_list_#{url_fragment(name)}_path".to_sym

    __send__(url, proceeding_id(application, ccms_code))
  end

  def url_fragment(name)
    I18n.t("providers.merits_task_lists.task_list_item.urls.#{name}")
  end

  def new_url_fragment(name, status, application)
    name = "has_other_involved_children" if name.eql?(:children_application) && (status.eql?(:complete) || application.involved_children.any?)
    name = "has_other_opponent" if name.eql?(:opponent_name) && (status.eql?(:complete) || application.opponents.any?)
    name = "opponent_type" if name.eql?(:opponent_name) && Setting.opponent_organisations?
    I18n.t("providers.merits_task_lists.task_list_item.urls.#{name}")
  end

  def proceeding_id(application, ccms_code)
    return nil unless ccms_code && application

    proceeding = application.proceedings.find_by(ccms_code:)
    proceeding.id
  end

  def display_new_page?(legal_aid_application, task_name)
    return false if Setting.opponent_organisations? && task_name.eql?(:opponent_name)
    return false unless %i[children_application opponent_name].include?(task_name)

    [
      starting_children_application_for_first_time?(legal_aid_application, task_name),
      starting_opponents_name_for_first_time?(legal_aid_application, task_name),
    ].any?(true)
  end

  def starting_children_application_for_first_time?(legal_aid_application, task_name)
    task_name.eql?(:children_application) && application_has_no_involved_children?(legal_aid_application)
  end

  def starting_opponents_name_for_first_time?(legal_aid_application, task_name)
    task_name.eql?(:opponent_name) && application_has_no_opponents?(legal_aid_application)
  end
end
