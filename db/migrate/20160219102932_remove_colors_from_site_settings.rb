class RemoveColorsFromSiteSettings < ActiveRecord::Migration
  def change
    remove_column :site_settings, :primary_color, :string
    remove_column :site_settings, :topbar_bg_color, :string
  end
end
