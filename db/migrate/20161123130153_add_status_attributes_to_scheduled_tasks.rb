class AddStatusAttributesToScheduledTasks < ActiveRecord::Migration
  def change
    add_column :scheduled_tasks, :last_run_start, :datetime
    add_column :scheduled_tasks, :last_run_successful_start, :datetime
    add_column :scheduled_tasks, :last_run_successful_end, :datetime
    add_column :scheduled_tasks, :last_run_unsuccessful_start, :datetime
    add_column :scheduled_tasks, :last_run_unsuccessful_end, :datetime
  end
end
