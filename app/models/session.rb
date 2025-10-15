# == Schema Information
#
# Table name: sessions
#
#  id                             :uuid             not null, primary key
#  data                           :jsonb
#  ip_address                     :string
#  prev_transaction_page_params   :jsonb
#  subscribed_at                  :datetime
#  user_agent                     :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  active_impersonator_session_id :uuid
#  user_id                        :uuid             not null
#
# Indexes
#
#  index_sessions_on_active_impersonator_session_id  (active_impersonator_session_id)
#  index_sessions_on_user_id                         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (active_impersonator_session_id => impersonation_sessions.id)
#  fk_rails_...  (user_id => users.id)
#
class Session < ApplicationRecord
  belongs_to :user
  belongs_to :active_impersonator_session,
    -> { where(status: :in_progress) },
    class_name: "ImpersonationSession",
    optional: true

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
  end

  def get_preferred_tab(tab_key)
    data.dig("tab_preferences", tab_key)
  end

  def set_preferred_tab(tab_key, tab_value)
    data["tab_preferences"] ||= {}
    data["tab_preferences"][tab_key] = tab_value
    save!
  end
end
