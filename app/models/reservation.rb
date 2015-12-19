class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule_item

  validates :user, presence: true
  validates :schedule_item, presence: true
  validate :schedule_item_cant_be_in_the_past

  def schedule_item_cant_be_in_the_past
    unless schedule_item.nil?
      if schedule_item.start < DateTime.now
        errors.add(:schedule_item, I18n.t('errors.cant_make_reservations_in_the_past'))
      end
    end
  end

  def schedule_item_cant_be_full
    unless schedule_item.nil?
      if schedule_item.reservations.count >= schedule_item.capacity
        errors.add(:schedule_item, I18n.t('errors.cant_make_reservations_for_full_items'))
      end
    end
  end
end
