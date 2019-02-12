module FlowHelper
  def next_action_buttons_with_form(url:, method: :post, show_draft: false)
    form_with(
      model: nil,
      url: url,
      method: method,
      local: true
    ) do |form|

      next_action_buttons(show_draft: show_draft, form: form)
    end
  end

  def next_action_buttons(form:, continue_id: :continue, show_draft: false)
    render(
      'shared/forms/next_action_buttons',
      continue_id: continue_id,
      form: form,
      show_draft: show_draft
    )
  end
end
