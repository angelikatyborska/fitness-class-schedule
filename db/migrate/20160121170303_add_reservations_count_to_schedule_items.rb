class AddReservationsCountToScheduleItems < ActiveRecord::Migration
  def change
    add_column :schedule_items, :reservations_count, :integer, default: 0
  end
end
