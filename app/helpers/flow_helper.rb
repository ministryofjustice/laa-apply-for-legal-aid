module FlowHelper
  def next_action_buttons_with_form(
    url:,
    method: :post,
    show_continue: true,
    show_draft: false,
    continue_button_text: t("generic.save_and_continue"),
    draft_button_text: t("generic.save_and_come_back_later")
  )

    form_with(model: nil, url:, method:, local: true) do |form|
      next_action_buttons(
        show_continue:,
        show_draft:,
        form:,
        continue_button_text:,
        draft_button_text:
      )
    end
  end

  def next_action_buttons(
    form:,
    continue_id: :continue,
    show_continue: true,
    show_draft: false,
    continue_button_text: t("generic.save_and_continue"),
    draft_button_text: t("generic.save_and_come_back_later")
  )

    render(
      "shared/forms/next_action_buttons",
      continue_id:,
      form:,
      show_continue:,
      show_draft:,
      continue_button_text:,
      draft_button_text:
    )
  end

  def next_action_link(continue_id: :continue, continue_text: t("generic.save_and_continue"), html_class: nil)
    klasses = ["govuk-button", html_class].compact.join(" ")
    link_to_accessible(continue_text, forward_path, id: continue_id, class: klasses)
  end
end
