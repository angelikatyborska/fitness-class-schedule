class TrainersController < ApplicationController
  expose(:trainers) do |default|
    default.order(:first_name)
  end

  expose(:trainer)
end