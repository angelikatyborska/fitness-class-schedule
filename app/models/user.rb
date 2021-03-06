class User < ActiveRecord::Base
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :reservations, dependent: :destroy
  has_many :schedule_items, through: :reservations

  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :without_reservation, -> (schedule_item) do
    self.where.not(id: schedule_item.users.map(&:id)).order(:last_name)
  end

  def admin?
    has_role?(:admin)
  end

  def reservation_for(schedule_item)
    reservations.find { |reservation| reservation.schedule_item == schedule_item }
  end

  def reservation_for?(schedule_item)
    !reservation_for(schedule_item).nil?
  end

  def to_s
    last_name + ', ' + first_name
  end

  def reliability
    past_reservations = reservations.to_a.count do |reservation|
      reservation.missed? || reservation.attended?
    end

    attended_reservations = reservations.to_a.count do |reservation|
      reservation.attended?
    end

    if past_reservations > 0
      attended_reservations.to_f / past_reservations
    else
      1
    end
  end
end
