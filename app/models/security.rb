# == Schema Information
#
# Table name: securities
#
#  id                     :uuid             not null, primary key
#  country_code           :string
#  exchange_acronym       :string
#  exchange_mic           :string
#  exchange_operating_mic :string
#  failed_fetch_at        :datetime
#  failed_fetch_count     :integer          default(0), not null
#  last_health_check_at   :datetime
#  logo_url               :string
#  name                   :string
#  offline                :boolean          default(FALSE), not null
#  ticker                 :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_securities_on_country_code                              (country_code)
#  index_securities_on_exchange_operating_mic                    (exchange_operating_mic)
#  index_securities_on_ticker_and_exchange_operating_mic_unique  (upper((ticker)::text), COALESCE(upper((exchange_operating_mic)::text), ''::text)) UNIQUE
#
class Security < ApplicationRecord
  include Provided

  before_validation :upcase_symbols

  has_many :trades, dependent: :nullify, class_name: "Trade"
  has_many :prices, dependent: :destroy

  validates :ticker, presence: true
  validates :ticker, uniqueness: { scope: :exchange_operating_mic, case_sensitive: false }

  scope :online, -> { where(offline: false) }

  def current_price
    @current_price ||= find_or_fetch_price
    return nil if @current_price.nil?
    Money.new(@current_price.price, @current_price.currency)
  end

  def to_combobox_option
    SynthComboboxOption.new(
      symbol: ticker,
      name: name,
      logo_url: logo_url,
      exchange_operating_mic: exchange_operating_mic,
      country_code: country_code
    )
  end

  private
    def upcase_symbols
      self.ticker = ticker.upcase
      self.exchange_operating_mic = exchange_operating_mic.upcase if exchange_operating_mic.present?
    end
end
