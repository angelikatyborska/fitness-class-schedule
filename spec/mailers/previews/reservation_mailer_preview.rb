# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer
class ReservationMailerPreview < ActionMailer::Preview
  def spot_freed
    ReservationMailer.spot_freed(Reservation.first)
  end

  def cancelled
    ReservationMailer.cancelled(Reservation.first)
  end
end
