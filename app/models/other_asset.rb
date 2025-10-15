# == Schema Information
#
# Table name: other_assets
#
#  id                :uuid             not null, primary key
#  locked_attributes :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class OtherAsset < ApplicationRecord
  include Accountable

  class << self
    def color
      "#12B76A"
    end

    def icon
      "plus"
    end

    def classification
      "asset"
    end
  end
end
