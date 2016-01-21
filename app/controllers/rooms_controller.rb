class RoomsController < ApplicationController
  expose(:rooms) do |default|
    default.order(:name)
  end

  expose(:room)
end