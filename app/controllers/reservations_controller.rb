class ReservationsController < ApplicationController
  expose(:user)
  expose(:reservations, ancestor: :user) do |default|
    default.includes(:schedule_item)
  end
  expose(:reservation)
end