class AddOutputFormatToTestResults < ActiveRecord::Migration[5.1]
  def change
    add_column :test_results, :output_format, :string, null: false, default: 'text'
  end
end
