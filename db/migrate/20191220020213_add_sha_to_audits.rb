class AddShaToAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :sha, :string
  end
end
