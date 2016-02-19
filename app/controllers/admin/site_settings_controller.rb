class Admin::SiteSettingsController < Admin::AdminApplicationController
  expose(:site_settings) { SiteSettings.instance }

  def update

    if site_settings.update(site_settings_params)
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
      :site_title
    )
  end
end