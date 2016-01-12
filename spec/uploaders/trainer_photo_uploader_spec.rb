require 'carrierwave/test/matchers'

RSpec.describe TrainerPhotoUploader do
  include CarrierWave::Test::Matchers

  let!(:trainer) { create(:trainer) }

  before do
    TrainerPhotoUploader.enable_processing = true
    @uploader = TrainerPhotoUploader.new(trainer, :photo)
    @uploader.store!(Rails.root.join('spec', 'fixtures', 'trainer.png').open)
  end

  after do
    TrainerPhotoUploader.enable_processing = false
    @uploader.remove!
  end

  it 'should make the image readable to all and writable only by owner' do
    @uploader.should have_permissions(0644)
  end
end