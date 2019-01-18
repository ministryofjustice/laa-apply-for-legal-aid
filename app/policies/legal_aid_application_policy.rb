class LegalAidApplicationPolicy < ApplicationPolicy
  def show?
    my_record?
  end

  def update?
    my_record?
  end

  private

  def my_record?
    record.provider_id == provider.id
  end
end
