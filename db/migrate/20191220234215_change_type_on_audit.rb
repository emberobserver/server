class ChangeTypeOnAudit < ActiveRecord::Migration[5.1]
  def change
    remove_column :audits, :type
    add_column :audits, :audit_type, :string
  end
end
