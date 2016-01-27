class Admin::ConfigurablesController < Admin::AdminApplicationController
  include ConfigurableEngine::ConfigurablesController

  def update
    should_refresh_stylesheets =
      ['topbar_bg_color', 'primary_color'].any? do |attribute|
        Configurable.public_send(attribute) != params[attribute.to_s]
      end
    super

    # For now this is the only way I know of
    # to force a new version of application.css to be compiled
    # when configurables are edited. Simply 'touching' the application.scss file
    # does not work, because the assets cache is based on the file's content
    # and not the modification date.
    Rails.cache.clear if should_refresh_stylesheets
  end
end