class LegalAidApplicationPolicy < ApplicationPolicy
  def index?
    my_record?
  end

  def show?
    my_record?
  end

  def update?
    my_record?
  end

  def destroy?
    my_record?
  end

  def create?
    my_record?
  end

  def remove_transaction_type?
    my_record?
  end

  private

  def my_record?
    record.provider_id == provider.id
  end
end
