# == Schema Information
#
# Table name: merchants
#
#  id                   :uuid             not null, primary key
#  color                :string
#  logo_url             :string
#  name                 :string           not null
#  source               :string
#  type                 :string           not null
#  website_url          :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  family_id            :uuid
#  provider_merchant_id :string
#
# Indexes
#
#  index_merchants_on_family_id           (family_id)
#  index_merchants_on_family_id_and_name  (family_id,name) UNIQUE WHERE ((type)::text = 'FamilyMerchant'::text)
#  index_merchants_on_source_and_name     (source,name) UNIQUE WHERE ((type)::text = 'ProviderMerchant'::text)
#  index_merchants_on_type                (type)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
class FamilyMerchant < Merchant
  COLORS = %w[#e99537 #4da568 #6471eb #db5a54 #df4e92 #c44fe9 #eb5429 #61c9ea #805dee #6ad28a]

  belongs_to :family

  before_validation :set_default_color

  validates :color, presence: true
  validates :name, uniqueness: { scope: :family }

  private
    def set_default_color
      self.color = COLORS.sample
    end
end
