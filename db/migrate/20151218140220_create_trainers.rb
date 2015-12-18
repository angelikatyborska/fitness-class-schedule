class CreateTrainers < ActiveRecord::Migration
  def change
    create_table :trainers do |t|
      t.string :first_name
      t.text :description

      t.timestamps null: false
    end
  end
end
