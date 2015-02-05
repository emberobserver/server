class DropEvaluationsMetricsAndReviewsTables < ActiveRecord::Migration
  def up
    drop_table :evaluations
    drop_table :metrics
    drop_table :reviews
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
