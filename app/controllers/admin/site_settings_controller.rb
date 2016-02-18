class Admin::SiteSettingsController < Admin::AdminApplicationController
  expose(:site_settings) { SiteSettings.instance }

  def update
    should_refresh_stylesheets =
      ['topbar_bg_color', 'primary_color'].any? do |attribute|
        SiteSettings.instance.public_send(attribute) != site_settings_params[attribute.to_s]
      end

    if site_settings.update(site_settings_params)
      # For now this is the only way I know of
      # to force a new version of application.css to be compiled
      # when configurables are edited. Simply 'touching' the application.scss file
      # does not work, because the assets cache is based on the file's content
      # and not the modification date.
      Rails.cache.clear if should_refresh_stylesheets

      redirect_to edit_admin_site_settings_path, notice: t('shared.updated_singular', resource: t('site_settings.name'))
    else
      render :edit
    end
  end

  private

  def site_settings_params
    params.require(:site_settings).permit(
      :day_start,
      :day_end,
      :time_zone,
      :cancellation_deadline,
      :email,
      :site_title,
      :primary_color,
      :topbar_bg_color
    )
  end
end