# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer
class ReservationMailerPreview < ActionMailer::Preview
  def spot_freed
    ReservationMailer.spot_freed(Reservation.first)
  end

  def cancelled
    ReservationMailer.cancelled(Reservation.first)
  end

  def edited
    reservation = Reservation.first
    changes = {
      start: [reservation.schedule_item.start, reservation.schedule_item.start + 1.day],
      capacity: [reservation.schedule_item.capacity, reservation.schedule_item.capacity + 5],
      duration: [reservation.schedule_item.duration, reservation.schedule_item.duration + 30],
      trainer: [reservation.schedule_item.trainer, Trainer.all.sample],
      room: [reservation.schedule_item.room, Room.all.sample],
      fitness_class: [reservation.schedule_item.fitness_class, FitnessClass.all.sample],
    }

    ReservationMailer.edited(reservation, changes)
  end
end
