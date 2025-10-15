# == Schema Information
#
# Table name: exchange_rates
#
#  id            :uuid             not null, primary key
#  date          :date             not null
#  from_currency :string           not null
#  rate          :decimal(, )      not null
#  to_currency   :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_exchange_rates_on_base_converted_date_unique  (from_currency,to_currency,date) UNIQUE
#  index_exchange_rates_on_from_currency               (from_currency)
#  index_exchange_rates_on_to_currency                 (to_currency)
#
class ExchangeRate < ApplicationRecord
  include Provided

  validates :from_currency, :to_currency, :date, :rate, presence: true
  validates :date, uniqueness: { scope: %i[from_currency to_currency] }
end
