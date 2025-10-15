# == Schema Information
#
# Table name: subscriptions
#
#  id                     :uuid             not null, primary key
#  amount                 :decimal(19, 4)
#  currency               :string
#  current_period_ends_at :datetime
#  interval               :string
#  status                 :string           not null
#  trial_ends_at          :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  family_id              :uuid             not null
#  stripe_id              :string
#
# Indexes
#
#  index_subscriptions_on_family_id  (family_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @family = Family.create!(name: "Test Family")
  end

  test "can create subscription without stripe details if trial" do
    subscription = Subscription.new(
      family: @family,
      status: :trialing,
    )

    assert_not subscription.valid?

    subscription.trial_ends_at = 14.days.from_now

    assert subscription.valid?
  end

  test "stripe details required for all statuses except trial" do
    subscription = Subscription.new(
      family: @family,
      status: :active,
    )

    assert_not subscription.valid?

    subscription.stripe_id = "test-stripe-id"

    assert subscription.valid?
  end
end
