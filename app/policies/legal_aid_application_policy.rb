class LegalAidApplicationPolicy < ApplicationPolicy
  def index?
    authorized_to_process?
  end

  def new?
    authorized_to_process?
  end

  def show?
    authorized_to_process?
  end

  def update?
    authorized_to_process?
  end

  def destroy?
    authorized_to_process?
  end

  def create?
    authorized_to_process?
  end

  def remove_transaction_type?
    authorized_to_process?
  end

  def continue?
    authorized_to_process?
  end

  def reset?
    authorized_to_process?
  end

  def show_submitted_application?
    authorized_to_view_submitted?
  end

  private

  def authorized_to_process?
    my_firms_record? && !record.submitted_to_ccms? && authorized_passported_permissions?
  end

  def authorized_to_view_submitted?
    my_firms_record? && authorized_passported_permissions?
  end

  def my_firms_record?
    record.provider.firm.id == provider.firm.id
  end

  def authorized_passported_permissions?
    return false if record.with_applicant? && !provider.non_passported_permissions?

    return true if @controller.respond_to?(:pre_dwp_check?) && @controller.pre_dwp_check? == true

    record.state_machine_proxy.is_a?(PassportedStateMachine) ? provider.passported_permissions? : provider.non_passported_permissions?
  end
end
