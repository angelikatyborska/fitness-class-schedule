class AddRoomToScheduleItems < ActiveRecord::Migration
  def change
    add_reference :schedule_items, :room, index: true, foreign_key: true
  end
end
