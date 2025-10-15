# == Schema Information
#
# Table name: cryptos
#
#  id                :uuid             not null, primary key
#  locked_attributes :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Crypto < ApplicationRecord
  include Accountable

  class << self
    def color
      "#737373"
    end

    def classification
      "asset"
    end

    def icon
      "bitcoin"
    end

    def display_name
      "Crypto"
    end
  end
end
