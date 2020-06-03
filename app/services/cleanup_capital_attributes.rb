class CleanupCapitalAttributes
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  attr_reader :legal_aid_application

  delegate(
    :own_home_no?, :own_home_owned_outright?, :own_home?, :shared_ownership?,
    to: :legal_aid_application
  )

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    when_own_home_no
    when_own_home_owned_outright
    when_shared_ownership_no
    legal_aid_application.save!
  end

  def when_own_home_no
    return unless own_home_no?

    legal_aid_application.attributes = {
      property_value: nil,
      outstanding_mortgage_amount: nil,
      shared_ownership: nil,
      percentage_home: nil
    }
  end

  def when_own_home_owned_outright
    return unless own_home_owned_outright?

    legal_aid_application.outstanding_mortgage_amount = nil
  end

  def when_shared_ownership_no
    return unless own_home? && !shared_ownership?

    legal_aid_application.percentage_home = nil
  end
end
