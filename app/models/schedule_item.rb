class ScheduleItem < ActiveRecord::Base
  belongs_to :trainer
  belongs_to :room
  has_many :reservations, dependent: :destroy
  has_many :users, through: :reservations

  validates :trainer, presence: true
  validates :room, presence: true
  validates :start, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :trainer, presence: true
  validates :activity, presence: true, inclusion: { in: proc { activities } }
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validate :duration_cant_span_multiple_days
  validate :start_cant_be_in_the_past
  validate :start_cant_be_before_day_start
  validate :start_cant_be_after_day_end
  validate :end_cant_be_after_day_end
  validate :room_cant_be_already_occupied
  validate :trainer_cant_be_already_occupied

  scope :week, -> (time = Time.zone.now) { where('start >= ? AND start < ?', time.beginning_of_week, time.beginning_of_week + 1.week)}


  def duration_cant_span_multiple_days
    unless duration.nil? || start.nil?
      stop = start + duration.minutes
      next_day = start.beginning_of_day + 1.day

      errors.add(:duration, I18n.t('errors.schedule_item.must_start_and_end_on_the_same_day')) if stop > next_day
    end
  end

  def start_cant_be_in_the_past
    unless start.nil?
      errors.add(:start, I18n.t('errors.cant_be_in_the_past')) if start < Time.zone.now
    end
  end

  def start_cant_be_before_day_start
    unless start.nil?
      if start < self.class.beginning_of_day(start)
        errors.add(:start, I18n.t('errors.schedule_item.cant_start_before_day_start'))
      end
    end
  end

  def start_cant_be_after_day_end
    unless start.nil? || duration.nil?
      if start > self.class.end_of_day(start)
        errors.add(:start, I18n.t('errors.schedule_item.cant_end_after_day_end'))
      end
    end
  end

  def end_cant_be_after_day_end
    unless start.nil? || duration.nil?
      if stop > self.class.end_of_day(stop)
        errors.add(:start, I18n.t('errors.schedule_item.cant_end_after_day_end'))
      end
    end
  end

  def room_cant_be_already_occupied
    unless start.nil? || room.nil?
      errors.add(:room, I18n.t('errors.occupied')) if room.occupied?(start, stop, except: self)
    end
  end

  def trainer_cant_be_already_occupied
    unless start.nil? || trainer.nil?
      errors.add(:trainer, I18n.t('errors.occupied')) if trainer.occupied?(start, stop, except: self)
    end
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

  def self.beginning_of_day(time)
    time.beginning_of_day + day_start.hours
  end

  def self.end_of_day(time)
    (time + 1.day).beginning_of_day - (24 - day_end).hours
  end

  def self.day_duration_in_quarters
    (day_end - day_start) * 4
  end

  def self.day_duration_in_hours
    day_duration_in_quarters / 4
  end

  def self.order_by_weekdays(schedule_items, week)
    weekdays = {}

    7.times do |n|
      weekdays[week.beginning_of_week + n.days] = []
    end

    schedule_items.order(:start).map do |item|
      weekdays[item.start.beginning_of_day] << item
    end

    weekdays
  end

  def self.activities
    %w(ABT TBC Step)
  end

  private

  def self.day_start
    @day_start ||= Configurable.day_start
  end

  def self.day_end
    @day_end ||= Configurable.day_end
  end
end