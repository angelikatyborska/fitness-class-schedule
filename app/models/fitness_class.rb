class FitnessClass < ActiveRecord::Base
  has_many :schedule_items, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :color, presence: true

  def to_s
    name
  end
end