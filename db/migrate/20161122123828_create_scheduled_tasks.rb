# frozen_string_literal: true

class CreateScheduledTasks < ActiveRecord::Migration
  def change
    create_table :scheduled_tasks do |t|
      t.string :scheduling
      t.string :task
      t.datetime :next_run

      t.timestamps null: false
    end
  end
end
