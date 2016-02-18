class CreateSiteSettings < ActiveRecord::Migration
  def change
    create_table :site_settings do |t|
      t.column :singleton_guard, :integer

      t.column :day_start, :integer
      t.column :day_end, :integer
      t.column :time_zone, :string
      t.column :cancellation_deadline, :integer

      t.column :site_title, :string
      t.column :email, :string

      t.column :primary_color, :string
      t.column :topbar_bg_color, :string

      t.timestamps
    end

    add_index(:site_settings, :singleton_guard, unique: true)
  end
end
