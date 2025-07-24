module Flow
  module Flows
    class ProviderDependants
      STEPS = {
        has_dependants: Steps::ProviderDependants::HasDependantsStep,
        dependants: Steps::ProviderDependants::DependantsStep,
        has_other_dependants: Steps::ProviderDependants::HasOtherDependantsStep,
        remove_dependants: Flow::Steps::ProviderDependants::RemoveDependantsStep,
      }.freeze
    end
  end
end
