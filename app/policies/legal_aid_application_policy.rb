class LegalAidApplicationPolicy < ApplicationPolicy
  def index?
    my_firms_unsubmitted_record?
  end

  def new?
    my_firms_unsubmitted_record?
  end

  def show?
    my_firms_unsubmitted_record?
  end

  def update?
    my_firms_unsubmitted_record?
  end

  def destroy?
    my_firms_unsubmitted_record?
  end

  def create?
    my_firms_unsubmitted_record?
  end

  def remove_transaction_type?
    my_firms_unsubmitted_record?
  end

  def continue?
    my_firms_unsubmitted_record?
  end

  def reset?
    my_firms_unsubmitted_record?
  end

  def show_submitted_application?
    my_firms_record?
  end

  private

  def my_firms_unsubmitted_record?
    my_firms_record? && !record.submitted_to_ccms?
  end

  def my_firms_record?
    record.provider.firm.id == provider.firm.id
  end
end
