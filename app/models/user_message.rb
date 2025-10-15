# == Schema Information
#
# Table name: messages
#
#  id          :uuid             not null, primary key
#  ai_model    :string
#  content     :text
#  debug       :boolean          default(FALSE)
#  reasoning   :boolean          default(FALSE)
#  status      :string           default("complete"), not null
#  type        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  chat_id     :uuid             not null
#  provider_id :string
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#
class UserMessage < Message
  validates :ai_model, presence: true

  after_create_commit :request_response_later

  def role
    "user"
  end

  def request_response_later
    chat.ask_assistant_later(self)
  end

  def request_response
    chat.ask_assistant(self)
  end
end
