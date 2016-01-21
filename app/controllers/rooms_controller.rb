class RoomsController < ApplicationController
  expose(:rooms) do |default|
    default.order(:name).includes([:room_photos])
  end

  expose(:room)
end