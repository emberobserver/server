class CreateLintResults < ActiveRecord::Migration[5.1]
  def change
    create_table :lint_results do |t|
      t.references :addon, foreign_key: true
      t.references :addon_version, foreign_key: true
      t.jsonb 'results'
      t.string 'sha'
      t.timestamps
    end
  end
end
