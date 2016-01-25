FactoryGirl.define do
  factory :room_photo do
    association :room
    photo { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', 'room.jpg')) }

    after :create do |reservation, evaluator|
      evaluator.room.reload
    end
  end
end
