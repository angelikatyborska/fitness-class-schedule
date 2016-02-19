class SiteSettings < ActiveRecord::Base
  self.table_name = 'site_settings'

  COLOR_REGEX = /\A#([a-f]|[A-F]|[0-9]){6}\Z/

  validates :singleton_guard, inclusion: { in: [0] }
  validates :day_start, inclusion: { in: (0..23) }
  validates :day_end, inclusion: { in: (1..24) }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  after_save { self.class.invalidate_cache }
  after_destroy { self.class.invalidate_cache }
  after_rollback { self.class.invalidate_cache }

  DEFAULTS = {
    day_start: 8,
    day_end: 23,
    time_zone: 'Warsaw',
    cancellation_deadline: 12,
    site_title: 'My Fitness Club',
    email: 'noreply@example.com',
    primary_color: '#2b7ac5',
    topbar_bg_color: '#333333'
  }

  column_names.each do |column|
    define_method(column.to_s) do
      self[column.to_sym] || DEFAULTS[column.to_sym]
    end

    define_method(column.to_s + '=') do |value|
      self[column.to_sym] = value
      self.class.invalidate_cache
    end
  end

  def self.instance
    @cache ||= (first || create(singleton_guard: 0))
  end

  def self.invalidate_cache
    @cache = nil
  end
end