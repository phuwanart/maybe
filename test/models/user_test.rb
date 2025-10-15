# == Schema Information
#
# Table name: users
#
#  id                            :uuid             not null, primary key
#  active                        :boolean          default(TRUE), not null
#  ai_enabled                    :boolean          default(FALSE), not null
#  default_period                :string           default("last_30_days"), not null
#  email                         :string
#  first_name                    :string
#  goals                         :text             default([]), is an Array
#  last_name                     :string
#  onboarded_at                  :datetime
#  otp_backup_codes              :string           default([]), is an Array
#  otp_required                  :boolean          default(FALSE), not null
#  otp_secret                    :string
#  password_digest               :string
#  role                          :string           default("member"), not null
#  rule_prompt_dismissed_at      :datetime
#  rule_prompts_disabled         :boolean          default(FALSE)
#  set_onboarding_goals_at       :datetime
#  set_onboarding_preferences_at :datetime
#  show_ai_sidebar               :boolean          default(TRUE)
#  show_sidebar                  :boolean          default(TRUE)
#  theme                         :string           default("system")
#  unconfirmed_email             :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  family_id                     :uuid             not null
#  last_viewed_chat_id           :uuid
#
# Indexes
#
#  index_users_on_email                (email) UNIQUE
#  index_users_on_family_id            (family_id)
#  index_users_on_last_viewed_chat_id  (last_viewed_chat_id)
#  index_users_on_otp_secret           (otp_secret) UNIQUE WHERE (otp_secret IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#  fk_rails_...  (last_viewed_chat_id => chats.id)
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:family_admin)
  end

  test "should be valid" do
    assert @user.valid?, @user.errors.full_messages.to_sentence
  end

  # email
  test "email must be present" do
    potential_user = User.new(
      email: "david@davidbowie.com",
      password_digest: BCrypt::Password.create("password"),
      first_name: "David",
      last_name: "Bowie"
    )
    potential_user.email = "     "
    assert_not potential_user.valid?
  end

  test "has email address" do
    assert_equal "bob@bobdylan.com", @user.email
  end

  test "can update email" do
    @user.update(email: "new_email@example.com")
    assert_equal "new_email@example.com", @user.email
  end

  test "email addresses must be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email address is normalized" do
    @user.update!(email: " UNIQUE-User@ExAMPle.CoM ")
    assert_equal "unique-user@example.com", @user.reload.email
  end

  test "display name" do
    user = User.new(email: "user@example.com")
    assert_equal "user@example.com", user.display_name
    user.first_name = "Bob"
    assert_equal "Bob", user.display_name
    user.last_name = "Dylan"
    assert_equal "Bob Dylan", user.display_name
  end

  test "initial" do
    user = User.new(email: "user@example.com")
    assert_equal "U", user.initial
    user.first_name = "Bob"
    assert_equal "B", user.initial
    user.first_name = nil
    user.last_name = "Dylan"
    assert_equal "D", user.initial
  end

  test "names are normalized" do
    @user.update!(first_name: "", last_name: "")
    assert_nil @user.first_name
    assert_nil @user.last_name

    @user.update!(first_name: " Bob ", last_name: " Dylan ")
    assert_equal "Bob", @user.first_name
    assert_equal "Dylan", @user.last_name
  end

  # MFA Tests
  test "setup_mfa! generates required fields" do
    user = users(:family_member)
    user.setup_mfa!

    assert user.otp_secret.present?
    assert_not user.otp_required?
    assert_empty user.otp_backup_codes
  end

  test "enable_mfa! enables MFA and generates backup codes" do
    user = users(:family_member)
    user.setup_mfa!
    user.enable_mfa!

    assert user.otp_required?
    assert_equal 8, user.otp_backup_codes.length
    assert user.otp_backup_codes.all? { |code| code.length == 8 }
  end

  test "disable_mfa! removes all MFA data" do
    user = users(:family_member)
    user.setup_mfa!
    user.enable_mfa!
    user.disable_mfa!

    assert_nil user.otp_secret
    assert_not user.otp_required?
    assert_empty user.otp_backup_codes
  end

  test "verify_otp? validates TOTP codes" do
    user = users(:family_member)
    user.setup_mfa!

    totp = ROTP::TOTP.new(user.otp_secret, issuer: "Maybe")
    valid_code = totp.now

    assert user.verify_otp?(valid_code)
    assert_not user.verify_otp?("invalid")
    assert_not user.verify_otp?("123456")
  end

  test "verify_otp? accepts backup codes" do
    user = users(:family_member)
    user.setup_mfa!
    user.enable_mfa!

    backup_code = user.otp_backup_codes.first
    assert user.verify_otp?(backup_code)

    # Backup code should be consumed
    assert_not user.otp_backup_codes.include?(backup_code)
    assert_equal 7, user.otp_backup_codes.length

    # Used backup code should not work again
    assert_not user.verify_otp?(backup_code)
  end

  test "provisioning_uri generates correct URI" do
    user = users(:family_member)
    user.setup_mfa!

    assert_match %r{otpauth://totp/}, user.provisioning_uri
    assert_match %r{secret=#{user.otp_secret}}, user.provisioning_uri
    assert_match %r{issuer=Maybe}, user.provisioning_uri
  end
end
