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
  validate :duration_cannot_span_multiple_days
  validate :start_cannot_be_in_the_past

  scope :week, -> (time = Time.zone.now) { where('start >= ? AND start < ?', time.beginning_of_week, time.beginning_of_week + 1.week)}


  def duration_cannot_span_multiple_days
    unless duration.nil? || start.nil?
      stop = start + duration.minutes
      next_day = start.beginning_of_day + 1.day

      errors.add(:duration, I18n.t('errors.schedule_item.must_start_and_end_on_the_same_day')) if stop > next_day
    end
  end

  def start_cannot_be_in_the_past
    unless start.nil?
      errors.add(:start, I18n.t('errors.cant_be_in_the_past')) if start < Time.zone.now
    end
  end

  def self.activities
    %w(ABT TBC Step)
  end
end