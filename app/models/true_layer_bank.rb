# frozen_string_literal: true

class TrueLayerBank < ApplicationRecord
  serialize :banks, Array

  scope :by_updated_at, -> { order(updated_at: :asc) }
  before_validation :populate_banks

  validates :banks, presence: true

  MOCK_BANK = {
    provider_id: 'mock',
    display_name: 'Mock Bank',
    logo_url: 'https://truelayer-client-logos.s3-eu-west-1.amazonaws.com/banks/banks-icons/mock-icon.svg'
  }.freeze

  def self.banks
    TrueLayerBanksUpdateWorker.perform_in 10.seconds
    instance = by_updated_at.last || create!
    return instance.banks unless mock_bank

    [mock_bank] + instance.banks
  end

  def self.mock_bank
    Rails.configuration.x.true_layer.enable_mock ? MOCK_BANK : nil
  end

  def populate_banks
    self.banks = TrueLayer::BanksRetriever.banks unless banks.present?
  end
end
