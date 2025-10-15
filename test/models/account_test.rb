# == Schema Information
#
# Table name: accounts
#
#  id                :uuid             not null, primary key
#  accountable_type  :string
#  balance           :decimal(19, 4)
#  cash_balance      :decimal(19, 4)   default(0.0)
#  classification    :string
#  currency          :string
#  locked_attributes :jsonb
#  name              :string
#  status            :string           default("active")
#  subtype           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  accountable_id    :uuid
#  family_id         :uuid             not null
#  import_id         :uuid
#  plaid_account_id  :uuid
#
# Indexes
#
#  index_accounts_on_accountable_id_and_accountable_type  (accountable_id,accountable_type)
#  index_accounts_on_accountable_type                     (accountable_type)
#  index_accounts_on_currency                             (currency)
#  index_accounts_on_family_id                            (family_id)
#  index_accounts_on_family_id_and_accountable_type       (family_id,accountable_type)
#  index_accounts_on_family_id_and_id                     (family_id,id)
#  index_accounts_on_family_id_and_status                 (family_id,status)
#  index_accounts_on_import_id                            (import_id)
#  index_accounts_on_plaid_account_id                     (plaid_account_id)
#  index_accounts_on_status                               (status)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#  fk_rails_...  (import_id => imports.id)
#  fk_rails_...  (plaid_account_id => plaid_accounts.id)
#
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include SyncableInterfaceTest, EntriesTestHelper

  setup do
    @account = @syncable = accounts(:depository)
    @family = families(:dylan_family)
  end

  test "can destroy" do
    assert_difference "Account.count", -1 do
      @account.destroy
    end
  end

  test "gets short/long subtype label" do
    account = @family.accounts.create!(
      name: "Test Investment",
      balance: 1000,
      currency: "USD",
      subtype: "hsa",
      accountable: Investment.new
    )

    assert_equal "HSA", account.short_subtype_label
    assert_equal "Health Savings Account", account.long_subtype_label

    # Test with nil subtype
    account.update!(subtype: nil)
    assert_equal "Investments", account.short_subtype_label
    assert_equal "Investments", account.long_subtype_label
  end
end
