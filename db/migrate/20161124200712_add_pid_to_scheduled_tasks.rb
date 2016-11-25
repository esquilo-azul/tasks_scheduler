class AddPidToScheduledTasks < ActiveRecord::Migration
  def change
    add_column :scheduled_tasks, :pid, :integer
  end
end
