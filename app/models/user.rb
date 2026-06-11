class User < ApplicationRecord
  ALLOWED_AVATAR_TYPES = ["image/png", "image/jpeg", "image/gif", "image/webp"].freeze
  MAX_AVATAR_SIZE = 5.megabytes

  has_secure_password
  has_one_attached :avatar

  validates :name, presence: true
  validates :email, presence: true,
    uniqueness: {case_sensitive: false},
    format: {with: URI::MailTo::EMAIL_REGEXP}
  validate :avatar_is_acceptable_image

  private

  def avatar_is_acceptable_image
    return unless avatar.attached?

    unless avatar.content_type.in?(ALLOWED_AVATAR_TYPES)
      errors.add(:avatar, "must be a PNG, JPEG, GIF, or WebP image")
    end

    if avatar.byte_size > MAX_AVATAR_SIZE
      errors.add(:avatar, "must be smaller than 5 MB")
    end
  end
end
