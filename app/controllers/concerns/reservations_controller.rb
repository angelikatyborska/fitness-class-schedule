class ReservationsController < ApplicationController
  expose(:user)
  expose(:reservations, ancestor: :user)
  expose(:reservation)
end