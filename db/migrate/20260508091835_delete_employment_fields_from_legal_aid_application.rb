class DeleteEmploymentFieldsFromLegalAidApplication < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_columns :legal_aid_applications, :extra_employment_information,
                                                                    :extra_employment_information_details,
                                                                    :full_employment_details, type: :string
    end
  end
end
