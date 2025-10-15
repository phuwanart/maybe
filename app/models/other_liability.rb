# == Schema Information
#
# Table name: other_liabilities
#
#  id                :uuid             not null, primary key
#  locked_attributes :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class OtherLiability < ApplicationRecord
  include Accountable

  class << self
    def color
      "#737373"
    end

    def icon
      "minus"
    end

    def classification
      "liability"
    end
  end
end
