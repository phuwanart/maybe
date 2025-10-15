# == Schema Information
#
# Table name: plaid_accounts
#
#  id                       :uuid             not null, primary key
#  available_balance        :decimal(19, 4)
#  currency                 :string           not null
#  current_balance          :decimal(19, 4)
#  mask                     :string
#  name                     :string           not null
#  plaid_subtype            :string
#  plaid_type               :string           not null
#  raw_investments_payload  :jsonb
#  raw_liabilities_payload  :jsonb
#  raw_payload              :jsonb
#  raw_transactions_payload :jsonb
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  plaid_id                 :string           not null
#  plaid_item_id            :uuid             not null
#
# Indexes
#
#  index_plaid_accounts_on_plaid_id       (plaid_id) UNIQUE
#  index_plaid_accounts_on_plaid_item_id  (plaid_item_id)
#
# Foreign Keys
#
#  fk_rails_...  (plaid_item_id => plaid_items.id)
#
class PlaidAccount < ApplicationRecord
  belongs_to :plaid_item

  has_one :account, dependent: :destroy

  validates :name, :plaid_type, :currency, presence: true
  validate :has_balance

  def upsert_plaid_snapshot!(account_snapshot)
    assign_attributes(
      current_balance: account_snapshot.balances.current,
      available_balance: account_snapshot.balances.available,
      currency: account_snapshot.balances.iso_currency_code,
      plaid_type: account_snapshot.type,
      plaid_subtype: account_snapshot.subtype,
      name: account_snapshot.name,
      mask: account_snapshot.mask,
      raw_payload: account_snapshot
    )

    save!
  end

  def upsert_plaid_transactions_snapshot!(transactions_snapshot)
    assign_attributes(
      raw_transactions_payload: transactions_snapshot
    )

    save!
  end

  def upsert_plaid_investments_snapshot!(investments_snapshot)
    assign_attributes(
      raw_investments_payload: investments_snapshot
    )

    save!
  end

  def upsert_plaid_liabilities_snapshot!(liabilities_snapshot)
    assign_attributes(
      raw_liabilities_payload: liabilities_snapshot
    )

    save!
  end

  private
    # Plaid guarantees at least one of these.  This validation is a sanity check for that guarantee.
    def has_balance
      return if current_balance.present? || available_balance.present?
      errors.add(:base, "Plaid account must have either current or available balance")
    end
end
