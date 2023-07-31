module Opponents
  class OrganisationForm < BaseForm
    form_for ApplicationMeritsTask::Opponent

    attr_accessor :name, :ccms_code, :description, :legal_aid_application

#     validates :name, :ccms_code, :description, presence: true, unless: :draft?

#     def save
#       return false unless valid?

#       model.legal_aid_application = legal_aid_application if legal_aid_application

#       if model.opposable
#         model.opposable.name = name
#         model.opposable.ccms_code = ccms_code
#         model.opposable.description = description
#         model.opposable.save!
#       else
#         model.opposable = ApplicationMeritsTask::Organisation.new(name:, ccms_code:, description:)
#       end
#       model.save!(validate: false)
#     end
#     alias_method :save!, :save
#   end
end
