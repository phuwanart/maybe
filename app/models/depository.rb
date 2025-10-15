# == Schema Information
#
# Table name: depositories
#
#  id                :uuid             not null, primary key
#  locked_attributes :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Depository < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "checking" => { short: "Checking", long: "Checking" },
    "savings" => { short: "Savings", long: "Savings" },
    "hsa" => { short: "HSA", long: "Health Savings Account" },
    "cd" => { short: "CD", long: "Certificate of Deposit" },
    "money_market" => { short: "MM", long: "Money Market" }
  }.freeze

  class << self
    def display_name
      "Cash"
    end

    def color
      "#875BF7"
    end

    def classification
      "asset"
    end

    def icon
      "landmark"
    end
  end
end
