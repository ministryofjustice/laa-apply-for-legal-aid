module FlowHelper
  def next_action_buttons_with_form(
    url:,
    method: :post,
    show_continue: true,
    show_draft: false,
    inverse_continue: false,
    continue_button_text: t("generic.save_and_continue"),
    draft_button_text: t("generic.save_and_come_back_later"),
    container_class: nil
  )
    form_with(url:, method:, local: true) do |form|
      next_action_buttons(
        show_continue:,
        show_draft:,
        inverse_continue:,
        form:,
        continue_button_text:,
        draft_button_text:,
        container_class:,
      )
    end
  end

  def next_action_buttons(
    form:,
    continue_id: :continue,
    show_continue: true,
    show_draft: false,
    inverse_continue: false,
    continue_button_text: t("generic.save_and_continue"),
    draft_button_text: t("generic.save_and_come_back_later"),
    container_class: nil
  )
    render(
      "shared/forms/next_action_buttons",
      continue_id:,
      form:,
      show_continue:,
      show_draft:,
      inverse_continue:,
      continue_button_text:,
      draft_button_text:,
      container_class: ["govuk-button-group", container_class].compact.join(" "),
    )
  end

  def next_action_link(continue_id: :continue, continue_text: t("generic.save_and_continue"), html_class: nil)
    klasses = ["govuk-button", html_class].compact.join(" ")
    govuk_link_to(continue_text, forward_path, id: continue_id, class: klasses)
  end
end
