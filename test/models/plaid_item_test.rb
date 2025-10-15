# == Schema Information
#
# Table name: plaid_items
#
#  id                      :uuid             not null, primary key
#  access_token            :string
#  available_products      :string           default([]), is an Array
#  billed_products         :string           default([]), is an Array
#  institution_color       :string
#  institution_url         :string
#  name                    :string
#  next_cursor             :string
#  plaid_region            :string           default("us"), not null
#  raw_institution_payload :jsonb
#  raw_payload             :jsonb
#  scheduled_for_deletion  :boolean          default(FALSE)
#  status                  :string           default("good"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  family_id               :uuid             not null
#  institution_id          :string
#  plaid_id                :string           not null
#
# Indexes
#
#  index_plaid_items_on_family_id  (family_id)
#  index_plaid_items_on_plaid_id   (plaid_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
require "test_helper"

class PlaidItemTest < ActiveSupport::TestCase
  include SyncableInterfaceTest

  setup do
    @plaid_item = @syncable = plaid_items(:one)
    @plaid_provider = mock
    Provider::Registry.stubs(:plaid_provider_for_region).returns(@plaid_provider)
  end

  test "removes plaid item when destroyed" do
    @plaid_provider.expects(:remove_item).with(@plaid_item.access_token).once

    assert_difference "PlaidItem.count", -1 do
      @plaid_item.destroy
    end
  end
end
