class MachineImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  process :fix_exif_rotation_and_strip_exif

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [240, 240]
  end

  def extension_allowlist
    %w[jpg jpeg pjpeg gif png]
  end

  def fix_exif_rotation_and_strip_exif
    manipulate! do |img|
      img = img.auto_orient
      img.strip!
      img = yield(img) if block_given?
      img
    end
  end
end
