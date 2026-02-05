module DependantHelper
  include CheckAnswersHelper

  ATTRIBUTES = %i[
    _name
    date_of_birth
    relationship
    in_full_time_education
    income
    assets
  ].freeze

  def dependant_hash(dependant)
    items = dependant_as_array(dependant)
    items&.compact!
    return nil if items.blank?

    {
      items:,
    }
  end

  def dependant_as_array(dependant)
    ATTRIBUTES&.map do |attribute|
      __send__(attribute, dependant)
    end
  end

  def _name(dependant)
    build_item_struct(
      t("name", scope: "providers.means.check_income_answers.dependants"),
      dependant.name,
    )
  end

  def date_of_birth(dependant)
    build_item_struct(
      t("date_of_birth", scope: "providers.means.check_income_answers.dependants"),
      dependant.date_of_birth&.strftime("%-d %B %Y"),
    )
  end

  def relationship(dependant)
    partner = dependant.legal_aid_application.applicant_has_partner? ? "_with_partner" : ""
    build_item_struct(
      t("relationship#{partner}", scope: "providers.means.check_income_answers.dependants"),
      dependant.relationship.nil? ? "" : t(dependant.relationship, scope: "shared.forms.dependants.relationship.option"),
    )
  end

  def in_full_time_education(dependant)
    build_item_struct(
      t("in_full_time_education", scope: "providers.means.check_income_answers.dependants"),
      yes_no(dependant.in_full_time_education),
    )
  end

  def income(dependant)
    build_item_struct(
      t("income", scope: "providers.means.check_income_answers.dependants"),
      dependant.has_income? ? gds_number_to_currency(dependant.monthly_income) : yes_no(dependant.has_income?),
    )
  end

  def assets(dependant)
    build_item_struct(
      t("assets", scope: "providers.means.check_income_answers.dependants"),
      dependant.has_assets_more_than_threshold? ? gds_number_to_currency(dependant.assets_value) : yes_no(dependant.has_assets_more_than_threshold?),
    )
  end
end
