module TaskListHelper
  def task_list_includes?(legal_aid_application, task_name)
    legal_aid_application.legal_framework_merits_task_list.serialized_data.match?(/name: :#{task_name}\n\s+dependencies: \*\d+/)
  end

  def _task_url(name, legal_aid_application, status)
    url = if name.eql?(:client_relationship_to_children)
            :"providers_legal_aid_application_#{new_proceeding_application_url_fragment(name, status)}_path"
          elsif display_new_page?(legal_aid_application, name)
            :"new_providers_legal_aid_application_#{url_fragment(name)}_path"
          else
            :"providers_legal_aid_application_#{new_url_fragment(name, status, legal_aid_application)}_path"
          end
    __send__(url, legal_aid_application)
  end

  def proceeding_task_url(name, application, ccms_code)
    url = :"providers_merits_task_list_#{url_fragment(name)}_path"

    __send__(url, proceeding_id(application, ccms_code))
  end

  def merits_task_list_empty_for?(legal_aid_application, proceeding)
    legal_aid_application.legal_framework_merits_task_list.task_list.tasks.dig(:proceedings, proceeding.ccms_code.to_sym)[:tasks].empty?
  end

private

  def application_has_no_involved_children?(legal_aid_application)
    legal_aid_application.involved_children.empty?
  end

  def new_proceeding_application_url_fragment(name, status)
    name = "client_check_parental_answer" if status.eql?(:complete)
    I18n.t("providers.merits_task_lists.show.urls.#{name}")
  end

  def url_fragment(name)
    I18n.t("providers.merits_task_lists.show.urls.#{name}")
  end

  def new_url_fragment(name, status, application)
    name = "has_other_involved_children" if name.eql?(:children_application) && (status.eql?(:complete) || application.involved_children.any?)
    name = "has_other_opponent" if name.eql?(:opponent_name) && (status.eql?(:complete) || application.opponents.any?)
    name = "opponent_type" if name.eql?(:opponent_name)
    I18n.t("providers.merits_task_lists.show.urls.#{name}")
  end

  def proceeding_id(application, ccms_code)
    return nil unless ccms_code && application

    proceeding = application.proceedings.find_by(ccms_code:)
    proceeding.id
  end

  def display_new_page?(legal_aid_application, task_name)
    task_name.eql?(:children_application) && application_has_no_involved_children?(legal_aid_application)
  end
end
