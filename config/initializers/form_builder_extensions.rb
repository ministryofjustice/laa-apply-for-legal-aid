ActiveSupport.on_load(:action_view) do
  require_dependency Rails.root.join("app/form_builders/form_builder_extensions/field_helpers").to_s
  ActionView::Helpers::FormBuilder.include FormBuilderExtensions::FieldHelpers
end
