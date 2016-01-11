class AddFitnessClassToScheduleItems < ActiveRecord::Migration
  def change
    add_reference :schedule_items, :fitness_class, index: true, foreign_key: true
  end
end
