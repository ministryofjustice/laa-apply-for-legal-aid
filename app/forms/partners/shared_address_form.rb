module Partners
  class SharedAddressForm < BaseForm
    form_for Partner

    attr_accessor :shared_address_with_client

    validates :shared_address_with_client, inclusion: %w[true false], unless: :draft?

    def shared_address_with_client?
      shared_address_with_client.eql?("true")
    end
  end
end
