class FitnessClassesController < ApplicationController
  expose(:fitness_classes) do |default|
    default.order(:name)
  end
end