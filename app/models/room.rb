class Room < ActiveRecord::Base
  has_many :schedule_items

  validates :name, presence: true
end
