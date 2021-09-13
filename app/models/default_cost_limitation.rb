class DefaultCostLimitation < ApplicationRecord
  belongs_to :proceeding_type

  enum cost_type: {
    delegated_functions: 'delegated_functions'.freeze,
    substantive: 'substantive'.freeze
  }

  def self.for_date(date)
    where('start_date <= ?', date).order(start_date: :desc).first
  end
end
