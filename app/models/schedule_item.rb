class ScheduleItem < ActiveRecord::Base
  before_destroy :send_cancellation_emails

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

  scope :week, -> (time = Time.zone.now) do
    where(
      'start >= ? AND start < ?',
      time.beginning_of_week,
      time.beginning_of_week + 1.week
    )
  end

  scope :hourly_time_frame, -> (from, to) { fitting_in_hourly_time_frame(from, to) }

  scope :trainer, -> (trainer) { where('trainer_id = ?', trainer) }
  scope :room, -> (room) { where('room_id = ?', room) }

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
      reservations.each { |reservation| ReservationMailer.cancelled(reservation).deliver_now }
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

  def spots_left
    (capacity - reservations.count) < 0 ? 0 : (capacity - reservations.count)
  end

  def full?
    spots_left < 1
  end

  def self.beginning_of_day(time)
    time.beginning_of_day + day_start.hours
  end

  def self.end_of_day(time)
    time.end_of_day - (24 - day_end).hours
  end

  def self.day_duration_in_quarters
    (day_end - day_start) * 4
  end

  def self.day_duration_in_hours
    day_duration_in_quarters / 4
  end

  private

  def self.fitting_in_hourly_time_frame(from, to)
    start_hour = '( extract(hour from start) )'
    stop_hour = '( extract(hour from start) + duration/60.0 )'

    if from < to
      query = "( #{ start_hour } BETWEEN ? AND ? ) AND ( #{ stop_hour } BETWEEN ? AND ? )"
      args = [from, to, from, to]
    else
      query =
        "(( #{ start_hour } BETWEEN ? AND ?) AND ( #{ stop_hour } BETWEEN ? AND ?)) " \
        "OR "\
        "(( #{ start_hour } BETWEEN ? AND ?) AND ( #{ stop_hour } BETWEEN ? AND ?))"
      args = [0, to, 0, to, from, 24, from, 24]
    end

    where(query, *args)
  end

  def self.day_start
    Configurable.day_start
  end

  def self.day_end
    Configurable.day_end
  end
end