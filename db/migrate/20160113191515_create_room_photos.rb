class CreateRoomPhotos < ActiveRecord::Migration
  def change
    create_table :room_photos do |t|
      t.string :photo
      t.references :room, index: true, foreign_key: true
    end
  end
end
