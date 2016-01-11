class RemoveActivityFromScheduleItems < ActiveRecord::Migration
  def change
    remove_column :schedule_items, :activity, :string
  end
end
