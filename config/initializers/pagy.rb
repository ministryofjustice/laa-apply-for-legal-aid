require "pagy/extras/overflow"

Pagy::I18n.load(locale: "en", filepath: Rails.root.join("config/locales/en/pagy.yml"))

Pagy::DEFAULT[:overflow] = :last_page
