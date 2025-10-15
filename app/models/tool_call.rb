# == Schema Information
#
# Table name: tool_calls
#
#  id                 :uuid             not null, primary key
#  function_arguments :jsonb
#  function_name      :string
#  function_result    :jsonb
#  type               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  message_id         :uuid             not null
#  provider_call_id   :string
#  provider_id        :string           not null
#
# Indexes
#
#  index_tool_calls_on_message_id  (message_id)
#
# Foreign Keys
#
#  fk_rails_...  (message_id => messages.id)
#
class ToolCall < ApplicationRecord
  belongs_to :message
end
