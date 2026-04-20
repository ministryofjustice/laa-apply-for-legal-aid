module EditingHelper
  # TODO: can we use legal aid application data to construct the array and perhaps use a state machine
  # to determine which section we are in and therefore whether it should be shownn. Or something like
  # sidebar displayable state set in the controller?! wrap up in a service class!
  #

  def editing_sidebar_items_for(path, legal_aid_application = nil)
    Editing::SidebarItems.new(path, legal_aid_application || resolve_application).call
  end

  # Disabling because we are doing this safely
  # rubocop:disable Rails/HelperInstanceVariable
  def resolve_application
    @legal_aid_application if defined?(@legal_aid_application)
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
