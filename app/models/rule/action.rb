# == Schema Information
#
# Table name: rule_actions
#
#  id          :uuid             not null, primary key
#  action_type :string           not null
#  value       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rule_id     :uuid             not null
#
# Indexes
#
#  index_rule_actions_on_rule_id  (rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (rule_id => rules.id)
#
class Rule::Action < ApplicationRecord
  belongs_to :rule, touch: true

  validates :action_type, presence: true

  def apply(resource_scope, ignore_attribute_locks: false)
    executor.execute(resource_scope, value: value, ignore_attribute_locks: ignore_attribute_locks)
  end

  def options
    executor.options
  end

  def value_display
    if value.present?
      if options
        options.find { |option| option.last == value }&.first
      else
        ""
      end
    else
      ""
    end
  end

  def executor
    rule.registry.get_executor!(action_type)
  end
end
