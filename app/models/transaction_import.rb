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
class TransactionImport < Import
  def import!
    transaction do
      mappings.each(&:create_mappable!)

      transactions = rows.map do |row|
        mapped_account = if account
          account
        else
          mappings.accounts.mappable_for(row.account)
        end

        category = mappings.categories.mappable_for(row.category)
        tags = row.tags_list.map { |tag| mappings.tags.mappable_for(tag) }.compact

        Transaction.new(
          category: category,
          tags: tags,
          entry: Entry.new(
            account: mapped_account,
            date: row.date_iso,
            amount: row.signed_amount,
            name: row.name,
            currency: row.currency,
            notes: row.notes,
            import: self
          )
        )
      end

      Transaction.import!(transactions, recursive: true)
    end
  end

  def required_column_keys
    %i[date amount]
  end

  def column_keys
    base = %i[date amount name currency category tags notes]
    base.unshift(:account) if account.nil?
    base
  end

  def mapping_steps
    base = [ Import::CategoryMapping, Import::TagMapping ]
    base << Import::AccountMapping if account.nil?
    base
  end

  def selectable_amount_type_values
    return [] if entity_type_col_label.nil?

    csv_rows.map { |row| row[entity_type_col_label] }.uniq
  end

  def csv_template
    template = <<-CSV
      date*,amount*,name,currency,category,tags,account,notes
      05/15/2024,-45.99,Grocery Store,USD,Food,groceries|essentials,Checking Account,Monthly grocery run
      05/16/2024,1500.00,Salary,,Income,,Main Account,
      05/17/2024,-12.50,Coffee Shop,,,coffee,,
    CSV

    csv = CSV.parse(template, headers: true)
    csv.delete("account") if account.present?
    csv
  end
end
