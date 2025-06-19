module Task
  class ConfirmClientDeclarations < Base
    def path
      providers_legal_aid_application_confirm_client_declaration_path(application)
    end
  end
end
