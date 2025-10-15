# == Schema Information
#
# Table name: data_enrichments
#
#  id              :uuid             not null, primary key
#  attribute_name  :string
#  enrichable_type :string           not null
#  metadata        :jsonb
#  source          :string
#  value           :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  enrichable_id   :uuid             not null
#
# Indexes
#
#  idx_on_enrichable_id_enrichable_type_source_attribu_5be5f63e08  (enrichable_id,enrichable_type,source,attribute_name) UNIQUE
#  index_data_enrichments_on_enrichable                            (enrichable_type,enrichable_id)
#
class DataEnrichment < ApplicationRecord
  belongs_to :enrichable, polymorphic: true

  enum :source, { rule: "rule", plaid: "plaid", synth: "synth", ai: "ai" }
end
