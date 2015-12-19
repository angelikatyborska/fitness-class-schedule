class ScheduleItem < ActiveRecord::Base
  belongs_to :trainer
  belongs_to :room
  has_many :reservations
  has_many :users, through: :reservations

  validates :start, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :trainer, presence: true
  validates :type, presence: true, inclusion: { in: proc { types } }
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validate :duration_cannot_span_multiple_days
  validate :start_cannot_be_in_the_past


  def duration_cannot_span_multiple_days
    unless duration.nil? || start.nil?
      stop = start + duration.minutes
      next_day = start.beginning_of_day + 1.day

      errors.add(:duration, I18n.t('errors.must_end_on_the_same_day')) if stop > next_day
    end
  end

  def start_cannot_be_in_the_past
    unless start.nil?
      errors.add(:start, I18n.t('errors.cant_be_in_the_past')) if start < DateTime.now
    end
  end

  def self.types
    %w(ABT TBC Step)
  end
end