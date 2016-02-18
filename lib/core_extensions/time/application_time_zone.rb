module CoreExtensions
  module Time
    module ApplicationTimeZone
      def in_website_time_zone
        in_time_zone(ActiveSupport::TimeZone[SiteSettings.instance.time_zone])
      end
    end
  end
end

ActiveSupport::TimeWithZone.include CoreExtensions::Time::ApplicationTimeZone