class AddSemverStringToTestResults < ActiveRecord::Migration
  def change
    add_column :test_results, :semver_string, :string
  end
end
