class Listing < ApplicationRecord
  mount_uploaders :photos, PhotoUploader
  # Associations
  belongs_to :user
  has_many :reservations, dependent: :destroy
  # Taggable
  acts_as_taggable_on :tags

  # Validation
  NON_VALIDATABLE_ATTRS = ["id", "created_at", "updated_at", "user", "photos", "verification"]
  #^or any other attribute that does not need validation
  VALIDATABLE_ATTRS = Listing.attribute_names.reject{|attr| NON_VALIDATABLE_ATTRS.include?(attr)}
  validates_presence_of VALIDATABLE_ATTRS
  #validating the presence of everything else
  validates :price_per_night, format: { with: /\A\d+(?:\.\d{0,2})?\z/, message:"has other characters besides numbers and decimal points." }, numericality: true
  validates :zipcode,:guest_pax, :bedroom_count, :bathroom_count, numericality: true
  validate :check_country

  def self.search(term)
    if term
      if self.country_code(term).nil?
        where('name ILIKE ? OR description ILIKE ? OR city ILIKE ? OR state ILIKE ?', "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%").order('id DESC')
      else
        where('name ILIKE ? OR description ILIKE ? OR country ILIKE ? OR city ILIKE ? OR state ILIKE ?', "%#{term}%", "%#{term}%", "%#{self.country_code(term)}%", "%#{term}%", "%#{term}%").order('id DESC')
      end
    else
      order('id DESC')
    end
  end

  def country_name
    country = ISO3166::Country[self.country]
    country.translations[I18n.locale.to_s] || country.name
  end

  def self.country_code(term)
    result = ISO3166::Country.translations.find { |key, value| term.include? value }
    if result.nil?
      nil
    else
      result[0]
    end
  end

  def check_country
    if !ISO3166::Country.translations.include? country
      errors.add(:country, "is not a valid country")
    end
  end

end
