# == Schema Information
#
# Table name: balances
#
#  id                     :uuid             not null, primary key
#  balance                :decimal(19, 4)   not null
#  cash_adjustments       :decimal(19, 4)   default(0.0), not null
#  cash_balance           :decimal(19, 4)   default(0.0)
#  cash_inflows           :decimal(19, 4)   default(0.0), not null
#  cash_outflows          :decimal(19, 4)   default(0.0), not null
#  currency               :string           default("USD"), not null
#  date                   :date             not null
#  end_balance            :decimal(19, 4)
#  end_cash_balance       :decimal(19, 4)
#  end_non_cash_balance   :decimal(19, 4)
#  flows_factor           :integer          default(1), not null
#  net_market_flows       :decimal(19, 4)   default(0.0), not null
#  non_cash_adjustments   :decimal(19, 4)   default(0.0), not null
#  non_cash_inflows       :decimal(19, 4)   default(0.0), not null
#  non_cash_outflows      :decimal(19, 4)   default(0.0), not null
#  start_balance          :decimal(19, 4)
#  start_cash_balance     :decimal(19, 4)   default(0.0), not null
#  start_non_cash_balance :decimal(19, 4)   default(0.0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :uuid             not null
#
# Indexes
#
#  index_account_balances_on_account_id_date_currency_unique  (account_id,date,currency) UNIQUE
#  index_balances_on_account_id                               (account_id)
#  index_balances_on_account_id_and_date                      (account_id,date DESC)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#
class Balance < ApplicationRecord
  include Monetizable

  belongs_to :account

  validates :account, :date, :balance, presence: true
  validates :flows_factor, inclusion: { in: [ -1, 1 ] }

  monetize :balance, :cash_balance,
           :start_cash_balance, :start_non_cash_balance, :start_balance,
           :cash_inflows, :cash_outflows, :non_cash_inflows, :non_cash_outflows, :net_market_flows,
           :cash_adjustments, :non_cash_adjustments,
           :end_cash_balance, :end_non_cash_balance, :end_balance

  scope :in_period, ->(period) { period.nil? ? all : where(date: period.date_range) }
  scope :chronological, -> { order(:date) }

  def balance_trend
    Trend.new(
      current: end_balance_money,
      previous: start_balance_money,
      favorable_direction: favorable_direction
    )
  end

  private

    def favorable_direction
      flows_factor == -1 ? "down" : "up"
    end
end
