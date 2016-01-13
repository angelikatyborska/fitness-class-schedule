class Admin::ConfigurablesController < Admin::AdminApplicationController
  include ConfigurableEngine::ConfigurablesController

  def update
    super

    # For now this is the only way I know of
    # to force a new version of application.css to be compiled
    # when configurables are edited. Simply 'touching' the application.scss file
    # does not work, because assets cache is based on file content
    # and not modification date.
    # TODO: probably think this through one more time
    FileUtils.rm_r Rails.root.join('tmp', 'cache', 'assets') unless Rails.env.test?
  end
end