module GroverOptionable
  extend ActiveSupport::Concern

  included do
  private

    def style_tag_options
      [
        content: Rails.root.join("app/assets/builds/application.css").read,
      ]
    end
  end
end
