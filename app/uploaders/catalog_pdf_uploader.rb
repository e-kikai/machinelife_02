class CatalogPdfUploader < CarrierWave::Uploader::Base
  # storage :file
  # storage :fog
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w[pdf]
  end

  version :thumb do
    def full_filename(for_file)
      super(for_file).sub(/\.pdf$/, '.jpeg')
    end

    process :pdf_first_page_to_jpg
    process resize_to_limit: [640, 640]
  end

  def pdf_first_page_to_jpg
    minimagick! do |pdf|
      pdf.loader(page: 0).convert('jpeg')
    end
  end
end
