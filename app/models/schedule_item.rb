class ScheduleItem < ActiveRecord::Base
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

  default_scope { includes(:reservations, :fitness_class, :trainer, :room) }

  scope :week, -> (time = Time.zone.now) { where('start >= ? AND start < ?', time.beginning_of_week, time.beginning_of_week + 1.week)}

  # TODO: write specs
  scope :trainer, -> (trainer) { where('trainer_id = ?', trainer) }
  scope :room, -> (room) { where('room_id = ?', room) }


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
    # TODO: write spec
    capacity - reservations.count
  end

  def full?
    # TODO: write spec
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

  def self.day_start
    Configurable.day_start
  end

  def self.day_end
    Configurable.day_end
  end
end