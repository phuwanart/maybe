# == Schema Information
#
# Table name: security_prices
#
#  id          :uuid             not null, primary key
#  currency    :string           default("USD"), not null
#  date        :date             not null
#  price       :decimal(19, 4)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  security_id :uuid
#
# Indexes
#
#  index_security_prices_on_security_id                        (security_id)
#  index_security_prices_on_security_id_and_date_and_currency  (security_id,date,currency) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (security_id => securities.id)
#
class Security::Price < ApplicationRecord
  belongs_to :security

  validates :date, :price, :currency, presence: true
  validates :date, uniqueness: { scope: %i[security_id currency] }
end
