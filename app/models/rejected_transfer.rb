# == Schema Information
#
# Table name: rejected_transfers
#
#  id                     :uuid             not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  inflow_transaction_id  :uuid             not null
#  outflow_transaction_id :uuid             not null
#
# Indexes
#
#  idx_on_inflow_transaction_id_outflow_transaction_id_412f8e7e26  (inflow_transaction_id,outflow_transaction_id) UNIQUE
#  index_rejected_transfers_on_inflow_transaction_id               (inflow_transaction_id)
#  index_rejected_transfers_on_outflow_transaction_id              (outflow_transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (inflow_transaction_id => transactions.id)
#  fk_rails_...  (outflow_transaction_id => transactions.id)
#
class RejectedTransfer < ApplicationRecord
  belongs_to :inflow_transaction, class_name: "Transaction"
  belongs_to :outflow_transaction, class_name: "Transaction"
end
