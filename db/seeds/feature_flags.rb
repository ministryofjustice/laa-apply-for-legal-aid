class FeatureFlagPopulate
  FEATURE_FLAGS = [
    # {
    #   name: :example_on_off,
    #   title: "Example on/off flag",
    #   description: "Example to create a standard, on/off, feature flag",
    # },
    {
      name: :means_test_review_a, # This should not be changed, it is the unique key for updates
      title: "Means Test Review: accelerated measures",
      description: "These are the accelerated measures required for the legislative change to the means test review",
      starts_at: {
        default: Time.zone.local(2024, 11, 1, 0, 0, 0),
        staging: Time.zone.local(2024, 11, 12, 0, 0, 0),
        production: Time.zone.local(2024, 11, 20, 0, 0, 0),
      },
    },
  ].freeze

  def run
    FEATURE_FLAGS.each do |feature|
      FeatureFlag.find_or_create_by!(name: feature[:name]) do |flag|
        flag.title = feature[:title]
        flag.description = feature[:description]
        if start_date(feature)
          flag.start_at = start_date(feature)
        else
          flag.active = false
        end
      end
    end

    # TODO: Run through each FeatureFlag and ensure it's in the array, destroying if it's not!
  end

private

  def start_date(feature)
    return nil if feature[:starts_at].nil?

    feature[:starts_at][HostEnv.environment] ||= feature[:starts_at][:default]
  end
end

FeatureFlagPopulate.new.run
