class Room < ActiveRecord::Base
  has_many :schedule_items, dependent: :nullify

  validates :name, presence: true

  include Occupiable
end
