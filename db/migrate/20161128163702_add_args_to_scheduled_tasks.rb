class AddArgsToScheduledTasks < ActiveRecord::Migration
  def change
    add_column :scheduled_tasks, :args, :string
  end
end