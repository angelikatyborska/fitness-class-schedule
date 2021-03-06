class ScheduleItem < ActiveRecord::Base
  before_destroy :send_cancellation_emails
  after_update :send_edited_emails

  belongs_to :trainer
  belongs_to :room
  belongs_to :fitness_class
  has_many :reservations, dependent: :destroy
  has_many :users, through: :reservations

  validates :trainer, presence: true
  validates :room, presence: true
  validates :start, presence: true
  validates :fitness_class, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :trainer, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validate :start_cant_be_in_the_past
  validate :room_cant_be_already_occupied
  validate :trainer_cant_be_already_occupied

  attr_reader :will_send_cancellation_emails

  scope :week, -> (time = Time.zone.now) do
    where(
      'start >= ? AND start < ?',
      time.beginning_of_week,
      time.beginning_of_week + 1.week
    )
  end

  scope :hourly_time_frame, -> (from, to) { fitting_in_hourly_time_frame(from, to) }

  scope :trainer, -> (trainer) { where(trainer: trainer) }
  scope :room, -> (room) { where(room: room) }

  scope :active, -> (time = Time.zone.now) { where('start >= ?', time) }
  scope :stale, -> (time = Time.zone.now) { where('start < ?', time) }

  def start_cant_be_in_the_past
    unless start.nil?
      errors.add(:start, I18n.t('errors.cant_be_in_the_past')) if start < Time.zone.now
    end
  end

  def room_cant_be_already_occupied
    unless start.nil? || duration.nil? || room.nil?
      errors.add(:room, I18n.t('errors.occupied')) if room.occupied?(start, stop, except: self)
    end
  end

  def trainer_cant_be_already_occupied
    unless start.nil? || duration.nil? || trainer.nil?
      errors.add(:trainer, I18n.t('errors.occupied')) if trainer.occupied?(start, stop, except: self)
    end
  end

  def send_cancellation_emails
    if start > Time.zone.now
      @will_send_cancellation_emails = true
      reservations.each { |reservation| ReservationMailer.cancelled(reservation).deliver_now }
    end
  end

  def send_edited_emails
    if changed?
      reservations.each do |reservation|
        ReservationMailer.edited(reservation, changes_without_timestamps_and_ids).deliver_now
      end
    end
  end

  def changes_without_timestamps_and_ids
    changes_without_timestamps = changes.except(:created_at, :updated_at)

    changes_without_timestamps.each.with_object({}) do |(key, values), hash|
      if key =~ /_id$/
        new_key = key.gsub(/_id$/, '')
        new_values = values.map { |id| new_key.classify.constantize.find(id) }
      else
        new_key = key
        new_values = values
      end

      hash[new_key] = new_values
    end
  end

  def to_s
    fitness_class.name
  end

  def stale?
    start < Time.zone.now
  end

  def going_on_at?(time)
    start <= time && start + duration.minutes > time
  end

  def going_on_between?(from, to)
    !((stop < from) || (start > to))
  end

  def stop
    start + duration.minutes
  end

  def free_spots
    (capacity - reservations.count) < 0 ? 0 : (capacity - reservations.count)
  end

  def full?
    free_spots < 1
  end

  def self.beginning_of_day(time)
    time.beginning_of_day + day_start.hours
  end

  def self.end_of_day(time)
    time.end_of_day - (24 - day_end).hours
  end

  def self.day_duration_in_quarters
    day_duration_in_hours * 4
  end

  def self.day_duration_in_hours
    day_end - day_start
  end

  private

  def self.fitting_in_hourly_time_frame(from, to)
    start_hour = '( extract(hour from start) )'
    stop_hour = '( extract(hour from start) + duration/60.0 )'

    if from < to
      query = "( #{ start_hour } BETWEEN :from AND :to ) AND ( #{ stop_hour } BETWEEN :from AND :to )"
      args = { from: from, to: to }
    else
      query =
        "(( #{ start_hour } BETWEEN :day_start AND :to) AND ( #{ stop_hour } BETWEEN :day_start AND :to)) " \
        "OR "\
        "(( #{ start_hour } BETWEEN :from AND :day_end) AND ( #{ stop_hour } BETWEEN :from AND :day_end))"
      args = { day_start: 0, to: to, from: from, day_end: 24 }
    end

    where(query, args)
  end

  def self.day_start
    SiteSettings.instance.day_start
  end

  def self.day_end
    SiteSettings.instance.day_end
  end
end