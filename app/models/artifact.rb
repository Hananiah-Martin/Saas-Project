class Artifact < ApplicationRecord
  # 1. Associations & Multi-tenancy
  acts_as_tenant(:tenant)
  belongs_to :project

  # 2. Active Storage Attachment
  # This replaces 'attr_accessor :upload' and connects to Cloudinary
  has_one_attached :upload

  # 3. Constants
  MAX_FILE_SIZE = 10.megabytes

  # 4. Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :project_id, message: "already exists in this project" }
  
  # Ensure the file is actually attached
  validates :upload, presence: true
  
  # Custom validation for file size
  validate :upload_size_within_limit

  private

  def upload_size_within_limit
    # Check if the attached file exists and exceeds the limit
    if upload.attached? && upload.blob.byte_size > MAX_FILE_SIZE
      errors.add(:upload, "file size must be less than #{MAX_FILE_SIZE / 1.megabyte} MB")
    end
  end
end