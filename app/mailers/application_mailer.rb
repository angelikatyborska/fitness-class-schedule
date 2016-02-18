class ApplicationMailer < ActionMailer::Base
  default from: SiteSettings.instance.email
  layout 'mailer'
end
