class RoomPhoto < ActiveRecord::Base
  belongs_to :room

  validates :room, presence: true
  validates :photo, presence: true

  mount_uploader :photo, RoomPhotoUploader
end