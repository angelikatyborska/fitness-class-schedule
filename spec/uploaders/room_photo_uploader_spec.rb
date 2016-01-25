require 'carrierwave/test/matchers'

RSpec.describe RoomPhotoUploader do
  include CarrierWave::Test::Matchers

  let!(:room) { create :room, name: 'Spinning room' }

  before do
    described_class.enable_processing = true
    @uploader = described_class.new(room.room_photos.new, :photo)
    @uploader.store!(Rails.root.join('spec', 'support', 'images', 'room.jpg').open)
  end

  after do
    described_class.enable_processing = false
    @uploader.remove!
  end

  it 'should make the image readable to all and writable only by owner' do
    expect(@uploader).to have_permissions(0644)
  end

  it 'should rename the file to room\'s name' do
    expect(@uploader.filename).to eq 'spinning_room.jpg'
  end

  context 'the thumb version' do
    it 'should scale down a photo to be exactly 200 by 200 pixels' do
      expect(@uploader.thumb).to have_dimensions(200, 200)
    end
  end
end