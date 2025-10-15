# == Schema Information
#
# Table name: impersonation_sessions
#
#  id              :uuid             not null, primary key
#  status          :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  impersonated_id :uuid             not null
#  impersonator_id :uuid             not null
#
# Indexes
#
#  index_impersonation_sessions_on_impersonated_id  (impersonated_id)
#  index_impersonation_sessions_on_impersonator_id  (impersonator_id)
#
# Foreign Keys
#
#  fk_rails_...  (impersonated_id => users.id)
#  fk_rails_...  (impersonator_id => users.id)
#
require "test_helper"

class ImpersonationSessionTest < ActiveSupport::TestCase
  test "only super admin can impersonate" do
    regular_user = users(:family_member)

    assert_not regular_user.super_admin?

    assert_raises(ActiveRecord::RecordInvalid) do
      ImpersonationSession.create!(
        impersonator: regular_user,
        impersonated: users(:maybe_support_staff)
      )
    end
  end

  test "super admin cannot be impersonated" do
    super_admin = users(:maybe_support_staff)

    assert super_admin.super_admin?

    assert_raises(ActiveRecord::RecordInvalid) do
      ImpersonationSession.create!(
        impersonator: users(:family_member),
        impersonated: super_admin
      )
    end
  end

  test "impersonation session must have different impersonator and impersonated" do
    super_admin = users(:maybe_support_staff)

    assert_raises(ActiveRecord::RecordInvalid) do
      ImpersonationSession.create!(
        impersonator: super_admin,
        impersonated: super_admin
      )
    end
  end
end
