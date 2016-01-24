class ApplicationMailer < ActionMailer::Base
  default from: Configurable.email
  layout 'mailer'
end
