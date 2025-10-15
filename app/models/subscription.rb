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
class Subscription < ApplicationRecord
  TRIAL_DAYS = 14

  belongs_to :family

  # https://docs.stripe.com/api/subscriptions/object
  enum :status, {
    incomplete: "incomplete",
    incomplete_expired: "incomplete_expired",
    trialing: "trialing", # We use this, but "offline" (no through Stripe's interface)
    active: "active",
    past_due: "past_due",
    canceled: "canceled",
    unpaid: "unpaid",
    paused: "paused"
  }

  validates :stripe_id, presence: true, if: :active?
  validates :trial_ends_at, presence: true, if: :trialing?
  validates :family_id, uniqueness: true

  class << self
    def new_trial_ends_at
      TRIAL_DAYS.days.from_now
    end
  end

  def name
    case interval
    when "month"
      "Monthly Plan"
    when "year"
      "Annual Plan"
    else
      "Free trial"
    end
  end
end
