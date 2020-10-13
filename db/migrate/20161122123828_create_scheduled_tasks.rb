# frozen_string_literal: true

class CreateScheduledTasks < (
    Rails.version < '5' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  )
  def change
    create_table :scheduled_tasks do |t|
      t.string :scheduling
      t.string :task
      t.datetime :next_run

      t.timestamps null: false
    end
  end
end
