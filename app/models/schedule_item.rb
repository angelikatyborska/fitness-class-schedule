class ScheduleItem < ActiveRecord::Base
  belongs_to :trainer
  belongs_to :room
  has_many :reservations, dependent: :destroy
  has_many :users, through: :reservations

  validates :start, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :trainer, presence: true
  validates :activity, presence: true, inclusion: { in: proc { activities } }
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validate :duration_cant_span_multiple_days
  validate :start_cant_be_in_the_past
  validate :start_cant_be_before_day_start

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
      if start.hour < Configurable.day_start
        errors.add(:start, I18n.t('errors.schedule_item.cant_start_before_day_start'))
      end
    end
  end

  def self.beginning_of_day(time)
    time.beginning_of_day + Configurable.day_start.hours
  end

  def self.end_of_day(time)
    (time + 1.day).beginning_of_day - (24 - Configurable.day_end).hours
  end

  def self.day_duration_in_quarters
    (Configurable.day_end - Configurable.day_start) * 4
  end

  def self.activities
    %w(ABT TBC Step)
  end
end