# == Schema Information
#
# Table name: families
#
#  id                       :uuid             not null, primary key
#  auto_sync_on_login       :boolean          default(TRUE), not null
#  country                  :string           default("US")
#  currency                 :string           default("USD")
#  data_enrichment_enabled  :boolean          default(FALSE)
#  date_format              :string           default("%m-%d-%Y")
#  early_access             :boolean          default(FALSE)
#  latest_sync_activity_at  :datetime
#  latest_sync_completed_at :datetime
#  locale                   :string           default("en")
#  name                     :string
#  timezone                 :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  stripe_customer_id       :string
#
require "test_helper"

class FamilyTest < ActiveSupport::TestCase
  include SyncableInterfaceTest

  def setup
    @syncable = families(:dylan_family)
  end
end
