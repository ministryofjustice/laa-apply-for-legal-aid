module Providers
  class CookiesForm < BaseForm
    form_for Provider

    attr_accessor :cookies_enabled

    validates :cookies_enabled, presence: true
  end
end
