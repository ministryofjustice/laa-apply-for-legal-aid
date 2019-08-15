class LegalAidApplicationPolicy < ApplicationPolicy
  def index?
    my_unsubmitted_record?
  end

  def show?
    my_unsubmitted_record?
  end

  def update?
    my_unsubmitted_record?
  end

  def destroy?
    my_unsubmitted_record?
  end

  def create?
    my_unsubmitted_record?
  end

  def remove_transaction_type?
    my_unsubmitted_record?
  end

  def continue?
    my_unsubmitted_record?
  end

  def reset?
    my_unsubmitted_record?
  end

  def show_submitted_application?
    my_record?
  end

  private

  def my_unsubmitted_record?
    my_record? && !record.assessment_submitted?
  end

  def my_record?
    record.provider_id == provider.id
  end
end
