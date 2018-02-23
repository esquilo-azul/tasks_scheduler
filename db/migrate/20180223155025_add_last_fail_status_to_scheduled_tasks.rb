class AddLastFailStatusToScheduledTasks < ActiveRecord::Migration
  def change
    add_column :scheduled_tasks, :last_fail_status, :string
  end
end
