class AddStatusToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :status, :integer, default: 0
  end
end
