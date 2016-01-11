class CreateFitnessClasses < ActiveRecord::Migration
  def change
    create_table :fitness_classes do |t|
      t.string :name
      t.text :description
      t.string :color
    end
  end
end
