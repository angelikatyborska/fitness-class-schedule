class TrainerDecorator < Draper::Decorator
  delegate_all

  def css_id
    "trainer-#{ id }"
  end
end