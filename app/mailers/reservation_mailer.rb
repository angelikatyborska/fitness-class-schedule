class ReservationMailer < ApplicationMailer
  def spot_freed(reservation)
    @schedule_item = reservation.schedule_item

    mail(
      to: reservation.user.email,
      subject: t(
        'reservation_mailer.spot_freed',
        schedule_item: "#{ reservation.schedule_item }, #{ l(reservation.schedule_item.start.in_website_time_zone, format: :human_friendly_date_with_weekday)}"))
  end

  def cancelled(reservation)
    @schedule_item = reservation.schedule_item

    mail(
      to: reservation.user.email,
      subject: t(
        'reservation_mailer.cancelled',
        schedule_item: "#{ reservation.schedule_item }, #{ l(reservation.schedule_item.start.in_website_time_zone, format: :human_friendly_date_with_weekday)}"))
  end
end
