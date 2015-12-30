class AddQueuePositionToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :queue_position, :integer
    add_index :reservations, :queue_position
  end
end
