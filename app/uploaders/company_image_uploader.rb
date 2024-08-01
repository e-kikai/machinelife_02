class CompanyImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # storage :file
  # storage :fog

  process :fix_exif_rotation_and_strip_exif

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
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
