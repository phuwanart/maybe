# == Schema Information
#
# Table name: import_mappings
#
#  id                :uuid             not null, primary key
#  create_when_empty :boolean          default(TRUE)
#  key               :string
#  mappable_type     :string
#  type              :string           not null
#  value             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  import_id         :uuid             not null
#  mappable_id       :uuid
#
# Indexes
#
#  index_import_mappings_on_import_id  (import_id)
#  index_import_mappings_on_mappable   (mappable_type,mappable_id)
#
class Import::AccountTypeMapping < Import::Mapping
  validates :value, presence: true

  class << self
    def mappables_by_key(import)
      import.rows.map(&:entity_type).uniq.index_with { nil }
    end
  end

  def selectable_values
    Accountable::TYPES.map { |type| [ type.titleize, type ] }
  end

  def requires_selection?
    true
  end

  def values_count
    import.rows.where(entity_type: key).count
  end

  def create_mappable!
    # no-op
  end
end
