require 'csv'

class ResultsPanelDecisionsPopulator
  def self.call
    new.call
  end

  def call
    file_path = Rails.root.join('db/seeds/results_panel_decisions.csv').freeze

    CSV.read(file_path, headers: true, header_converters: :symbol).each do |row|
      results_panel_decision = ResultsPanelDecision.where(cfe_result: row[:cfe_result],
                                                          disregards: row[:disregards],
                                                          restrictions: row[:restrictions],
                                                          extra_employment_information: row[:extra_employment_information]).first_or_initialize
      results_panel_decision.update! row.to_h
    end
  end
end
