class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule_item

  enum status: [:active, :queued, :missed]

  validates :user, presence: true, uniqueness: { scope: :schedule_item_id }
  validates :schedule_item, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
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
end
