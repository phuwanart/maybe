# == Schema Information
#
# Table name: addresses
#
#  id               :uuid             not null, primary key
#  addressable_type :string
#  country          :string
#  county           :string
#  line1            :string
#  line2            :string
#  locality         :string
#  postal_code      :integer
#  region           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :uuid
#
# Indexes
#
#  index_addresses_on_addressable  (addressable_type,addressable_id)
#
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  def to_s
    string = I18n.t("address.format",
      line1: line1,
      line2: line2,
      county: county,
      locality: locality,
      region: region,
      country: country,
      postal_code: postal_code
    )

    # Clean up the string to maintain I18n comma formatting
    string.split(",").map(&:strip).reject(&:empty?).join(", ")
  end
end
