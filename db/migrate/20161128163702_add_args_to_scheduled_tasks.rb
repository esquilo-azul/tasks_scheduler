# frozen_string_literal: true

class AddArgsToScheduledTasks < (
    Rails.version < '5.2' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  )
  def change
    add_column :scheduled_tasks, :args, :string
  end
end
