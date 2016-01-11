class FitnessClassDecorator < Draper::Decorator
  delegate_all

  def css_id
    "fitness-class-#{ id }"
  end
end