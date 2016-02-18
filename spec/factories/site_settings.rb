FactoryGirl.define do
  factory :site_settings do
    sequence(:primary_color) { |n| '#' + ('aaa'..'fff').to_a[n] }
    sequence(:topbar_bg_color) { |n| '#' + ('aaa'..'fff').to_a[n] }
    sequence(:email) { |n| "noreply#{ n }@example.com" }
    sequence(:site_title) { |n| "My Fitness Club #{ n }" }
    sequence(:day_start) { |n| n % 23 }
    sequence(:day_end) { |n| (n % 23) + 1 }
    sequence(:cancellation_deadline) { |n| (n % 12) + 1 }
    sequence(:time_zone) { |n| ActiveSupport::TimeZone.all.map(&:name)[n] }
  end
end