# == Schema Information
#
# Table name: invite_codes
#
#  id         :uuid             not null, primary key
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_invite_codes_on_token  (token) UNIQUE
#
class InviteCode < ApplicationRecord
  before_validation :generate_token, on: :create

  class << self
    def claim!(token)
      if invite_code = find_by(token: token&.downcase)
        invite_code.destroy!
        true
      end
    end

    def generate!
      create!.token
    end
  end

  private

    def generate_token
      loop do
        self.token = SecureRandom.hex(4)
        break token unless self.class.exists?(token: token)
      end
    end
end
