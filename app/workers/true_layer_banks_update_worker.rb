class TrueLayerBanksUpdateWorker
  DataRetrievalError = Class.new(StandardError)
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  UPDATE_INTERVAL = 1.hour

  def perform
    return true if last_updated && last_updated.updated_at > UPDATE_INTERVAL.ago
    return last_updated.touch if last_updated && stored_data_current?

    lastest_data.save!
  end

  def last_updated
    @last_updated ||= TrueLayerBank.by_updated_at.last
  end

  def lastest_data
    @lastest_data ||= begin
      true_layer_bank = TrueLayerBank.new
      true_layer_bank.populate_banks
      true_layer_bank
    end
  end

  def stored_data_current?
    last_updated.banks == lastest_data.banks
  end
end
