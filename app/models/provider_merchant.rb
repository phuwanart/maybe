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
class ProviderMerchant < Merchant
  enum :source, { plaid: "plaid", synth: "synth", ai: "ai" }

  validates :name, uniqueness: { scope: [ :source ] }
  validates :source, presence: true
end
