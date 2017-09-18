class User < ApplicationRecord
  # Associations
  has_many :authentications, dependent: :destroy
  has_many :listings, dependent: :destroy

  include Clearance::User
  # Validation
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :first_name,:last_name, :email, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum:7, too_short: "Password must be at least 7 characters long" }

  def user_listings
  end

  # FB
  def self.create_with_auth_and_hash(authentication, auth_hash)
    user = self.create!(
    # If you dont know how to call it, use byebug and auto_hash to see how to call it
      first_name: auth_hash["extra"]["raw_info"]["first_name"],
      last_name: auth_hash["extra"]["raw_info"]["last_name"],
      email: auth_hash["extra"]["raw_info"]["email"],
      password: SecureRandom.hex(7)
    )
    # This connects the authentication to this user
    user.authentications << authentication
    return user
  end

  # grab fb_token to access Facebook for user data
  def fb_token
    x = self.authentications.find_by(provider: 'facebook')
    return x.token unless x.nil?
  end

  def capitalize
    self.first_name = self.first_name.capitalize
    self.last_name = self.last_name.capitalize
    self.email = self.email.downcase
  end

  def full_name
    self.first_name + " " + self.last_name
  end

end
