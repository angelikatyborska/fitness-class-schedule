class RemoveQueuePositionFromReservations < ActiveRecord::Migration
  def change
    remove_column :reservations, :queue_position, :integer
  end
end
