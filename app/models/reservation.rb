class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule_item

  before_validation :set_initial_queue_position, on: :create
  before_destroy :update_other_reservations

  enum status: [:active, :queued, :missed]

  validates :user, presence: true, uniqueness: { scope: :schedule_item_id }
  validates :schedule_item, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  # TODO: resolve
  #validates :queue_position, presence: true
  validate :schedule_item_cant_be_in_the_past
  validate :schedule_item_cant_be_full

  def schedule_item_cant_be_in_the_past
    unless schedule_item.nil?
      if schedule_item.start < Time.zone.now
        errors.add(:schedule_item, I18n.t('errors.reservation.cant_make_reservations_in_the_past'))
      end
    end
  end

  def schedule_item_cant_be_full
    unless schedule_item.nil?
      if schedule_item.reservations.count >= schedule_item.capacity
        errors.add(:schedule_item, I18n.t('errors.reservation.cant_make_reservations_for_full_items'))
      end
    end
  end

  def update_status
    if queue_position >= schedule_item.capacity
      self.status = 'queued'
    else
      self.status = 'active'
    end
  end

  private

  def update_other_reservations
    schedule_item.reservations.each do |reservation|
      reservation.queue_position -= 1 if reservation.queue_position > self.queue_position
      reservation.update_status
      reservation.save
    end
  end

  def set_initial_queue_position
    if schedule_item && schedule_item.reservations
      number_of_reservations_before = schedule_item.reservations.length

      self.queue_position = number_of_reservations_before + 1
    end
  end
end
