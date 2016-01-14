class Room < ActiveRecord::Base
  has_many :schedule_items, dependent: :nullify
  has_many :room_photos, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  include Occupiable

  def to_s
    name
  end
end
