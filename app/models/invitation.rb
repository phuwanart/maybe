# == Schema Information
#
# Table name: invitations
#
#  id          :uuid             not null, primary key
#  accepted_at :datetime
#  email       :string
#  expires_at  :datetime
#  role        :string
#  token       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  family_id   :uuid             not null
#  inviter_id  :uuid             not null
#
# Indexes
#
#  index_invitations_on_email                (email)
#  index_invitations_on_email_and_family_id  (email,family_id) UNIQUE
#  index_invitations_on_family_id            (family_id)
#  index_invitations_on_inviter_id           (inviter_id)
#  index_invitations_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#  fk_rails_...  (inviter_id => users.id)
#
class Invitation < ApplicationRecord
  belongs_to :family
  belongs_to :inviter, class_name: "User"

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :token, presence: true, uniqueness: true
  validates_uniqueness_of :email, scope: :family_id, message: "has already been invited to this family"
  validate :inviter_is_admin

  before_validation :generate_token, on: :create
  before_create :set_expiration

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  def pending?
    accepted_at.nil? && expires_at > Time.current
  end

  private

    def generate_token
      loop do
        self.token = SecureRandom.hex(32)
        break unless self.class.exists?(token: token)
      end
    end

    def set_expiration
      self.expires_at = 3.days.from_now
    end

    def inviter_is_admin
      inviter.admin?
    end
end
