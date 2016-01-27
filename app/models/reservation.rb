class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule_item, counter_cache: true

  enum status: [:active, :attended, :missed]
  after_destroy :send_email_for_freed_spot

  validates :user, presence: true, uniqueness: { scope: :schedule_item_id }
  validates :schedule_item, presence: true
  validate :schedule_item_cant_be_in_the_past, on: :create
  validate :only_status_can_be_changed, on: :update

  def schedule_item_cant_be_in_the_past
    unless schedule_item.nil?
      if schedule_item.start < Time.zone.now
        errors.add(:schedule_item, I18n.t('errors.reservation.cant_make_reservations_in_the_past'))
      end
    end
  end

  def only_status_can_be_changed
    changed.each do |attribute|
      if attribute != 'status'
        errors.add(attribute.to_sym, I18n.t('errors.reservation.only_status_can_be_changed'))
      end
    end
  end

  def queued?
    queue_position > schedule_item.capacity
  end

  def queue_position
    if schedule_item && schedule_item.reservations
      number_of_reservations_before = schedule_item.reservations.to_a.count do |reservation|
        reservation.created_at.iso8601(10) < created_at.iso8601(10)
      end

      number_of_reservations_before + 1
    end
  end

  def send_email_for_freed_spot
    unless schedule_item.will_send_cancellation_emails || schedule_item.start < Time.zone.now
      if queue_position <= schedule_item.capacity
        reservation_next_in_line =
          schedule_item.reload.reservations.find do |reservation|
            reservation.queue_position == schedule_item.capacity
          end

        unless reservation_next_in_line.nil? || reservation_next_in_line == self
          ReservationMailer.spot_freed(reservation_next_in_line).deliver_now
        end
      end
    end
  end
end
