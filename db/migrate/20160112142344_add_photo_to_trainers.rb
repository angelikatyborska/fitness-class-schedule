class AddPhotoToTrainers < ActiveRecord::Migration
  def change
    add_column :trainers, :photo, :string
  end
end
