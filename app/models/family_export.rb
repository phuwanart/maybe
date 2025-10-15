# == Schema Information
#
# Table name: family_exports
#
#  id         :uuid             not null, primary key
#  status     :string           default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  family_id  :uuid             not null
#
# Indexes
#
#  index_family_exports_on_family_id  (family_id)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
class FamilyExport < ApplicationRecord
  belongs_to :family

  has_one_attached :export_file

  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, default: :pending, validate: true

  scope :ordered, -> { order(created_at: :desc) }

  def filename
    "maybe_export_#{created_at.strftime('%Y%m%d_%H%M%S')}.zip"
  end

  def downloadable?
    completed? && export_file.attached?
  end
end
