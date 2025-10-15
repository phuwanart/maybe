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
class ToolCall::Function < ToolCall
  validates :function_name, :function_result, presence: true
  validates :function_arguments, presence: true, allow_blank: true

  class << self
    # Translates an "LLM Concept" provider's FunctionRequest into a ToolCall::Function
    def from_function_request(function_request, result)
      new(
        provider_id: function_request.id,
        provider_call_id: function_request.call_id,
        function_name: function_request.function_name,
        function_arguments: function_request.function_args,
        function_result: result
      )
    end
  end

  def to_result
    {
      call_id: provider_call_id,
      output: function_result
    }
  end
end
