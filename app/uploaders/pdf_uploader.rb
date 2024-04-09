class PdfUploader < CarrierWave::Uploader::Base
  storage :file
  # storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w[pdf]
  end
end
