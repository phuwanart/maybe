# == Schema Information
#
# Table name: imports
#
#  id                               :uuid             not null, primary key
#  account_col_label                :string
#  amount_col_label                 :string
#  amount_type_inflow_value         :string
#  amount_type_strategy             :string           default("signed_amount")
#  category_col_label               :string
#  col_sep                          :string           default(",")
#  column_mappings                  :jsonb
#  currency_col_label               :string
#  date_col_label                   :string
#  date_format                      :string           default("%m/%d/%Y")
#  entity_type_col_label            :string
#  error                            :string
#  exchange_operating_mic_col_label :string
#  name_col_label                   :string
#  normalized_csv_str               :string
#  notes_col_label                  :string
#  number_format                    :string
#  price_col_label                  :string
#  qty_col_label                    :string
#  raw_file_str                     :string
#  signage_convention               :string           default("inflows_positive")
#  status                           :string
#  tags_col_label                   :string
#  ticker_col_label                 :string
#  type                             :string           not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  account_id                       :uuid
#  family_id                        :uuid             not null
#
# Indexes
#
#  index_imports_on_family_id  (family_id)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
class AccountImport < Import
  OpeningBalanceError = Class.new(StandardError)

  def import!
    transaction do
      rows.each do |row|
        mapping = mappings.account_types.find_by(key: row.entity_type)
        accountable_class = mapping.value.constantize

        account = family.accounts.build(
          name: row.name,
          balance: row.amount.to_d,
          currency: row.currency,
          accountable: accountable_class.new,
          import: self
        )

        account.save!

        manager = Account::OpeningBalanceManager.new(account)
        result = manager.set_opening_balance(balance: row.amount.to_d)

        # Re-raise since we should never have an error here
        if result.error
          raise OpeningBalanceError, result.error
        end
      end
    end
  end

  def mapping_steps
    [ Import::AccountTypeMapping ]
  end

  def required_column_keys
    %i[name amount]
  end

  def column_keys
    %i[entity_type name amount currency]
  end

  def dry_run
    {
      accounts: rows.count
    }
  end

  def csv_template
    template = <<-CSV
      Account type*,Name*,Balance*,Currency
      Checking,Main Checking Account,1000.00,USD
      Savings,Emergency Fund,5000.00,USD
      Credit Card,Rewards Card,-500.00,USD
    CSV

    CSV.parse(template, headers: true)
  end

  def max_row_count
    50
  end
end
