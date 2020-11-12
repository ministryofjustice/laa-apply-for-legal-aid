class AddScopeLimitationService
  def initialize(legal_aid_application, delegate)
    @legal_aid_application = legal_aid_application
    @delegate = delegate
  end

  def self.call(legal_aid_application, delegate)
    new(legal_aid_application, delegate).call
  end

  def call
    if @delegate
      add_default_delegated_functions_scope_limitation!
    else
      add_default_substantive_scope_limitation!
    end
  end

  def add_default_substantive_scope_limitation!
    ApplicationScopeLimitation.create!(
      legal_aid_application: @legal_aid_application,
      scope_limitation: @legal_aid_application.lead_proceeding_type.default_substantive_scope_limitation,
      substantive: true
    )
  end

  def add_default_delegated_functions_scope_limitation!
    ApplicationScopeLimitation.create!(
      legal_aid_application: @legal_aid_application,
      scope_limitation: @legal_aid_application.lead_proceeding_type.default_delegated_functions_scope_limitation,
      substantive: false
    )
  end
end
