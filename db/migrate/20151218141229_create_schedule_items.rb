class CreateScheduleItems < ActiveRecord::Migration
  def change
    create_table :schedule_items do |t|
      t.datetime :start
      t.integer :duration
      t.string :type
      t.integer :capacity
      t.references :trainer, index: true, foreign_key: true

      t.timestamps null: false

      t.index :start
      t.index :duration
    end
  end
end
