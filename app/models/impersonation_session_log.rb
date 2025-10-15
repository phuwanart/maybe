# == Schema Information
#
# Table name: impersonation_session_logs
#
#  id                       :uuid             not null, primary key
#  action                   :string
#  controller               :string
#  ip_address               :string
#  method                   :string
#  path                     :text
#  user_agent               :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  impersonation_session_id :uuid             not null
#
# Indexes
#
#  index_impersonation_session_logs_on_impersonation_session_id  (impersonation_session_id)
#
# Foreign Keys
#
#  fk_rails_...  (impersonation_session_id => impersonation_sessions.id)
#
class ImpersonationSessionLog < ApplicationRecord
  belongs_to :impersonation_session
end
