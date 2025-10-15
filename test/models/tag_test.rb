# == Schema Information
#
# Table name: tags
#
#  id         :uuid             not null, primary key
#  color      :string           default("#e99537"), not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  family_id  :uuid             not null
#
# Indexes
#
#  index_tags_on_family_id  (family_id)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "replace and destroy" do
    old_tag = tags(:one)
    new_tag = tags(:two)

    assert_difference "Tag.count", -1 do
      old_tag.replace_and_destroy!(new_tag)
    end

    old_tag.transactions.each do |txn|
      txn.reload
      assert_includes txn.tags, new_tag
      assert_not_includes txn.tags, old_tag
    end
  end
end
