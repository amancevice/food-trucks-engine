class Place < ActiveRecord::Base
  include Like

  has_many :patterns, class_name:"PlacePattern"

  validates :place, :geoname, :city, :latitude, :longitude, presence: true
  validates :place, uniqueness: {scope: :city}

  before_validation :geocache

  geocoded_by :geoname
  reverse_geocoded_by :latitude, :longitude, address: :place

  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :nearby, -> args { where id:select{|x| x.nearby? args }.collect(&:id) }
  scope :match, -> args {
    places = args[:city].nil? ? Place.all : Place.where(city:args[:city])
    places.like(args[:place]).first ||
      places.nearby(lat:args[:latitude], lng:args[:longitude], max:args[:dist]||0.05).first ||
      places.near("#{args[:place]} #{args[:city]}".strip, args[:dist]||0.05, units: :km).first ||
      Unknown.new(args.slice(:city, :place, :latitude, :longitude, :source, :timezone))
  }

  def name
    place
  end

  def geocache
    self.geoname ||= "#{name} #{city}"
    geocode if latitude.nil? || longitude.nil?
  end

  def nearby? lat:nil, lng:nil, max:0.05
    unless lat.nil? || lng.nil? || latitude.nil? || longitude.nil?
      r    = 6371.0
      dlat = (lat - latitude)  * Math::PI / 180.0
      dlng = (lng - longitude) * Math::PI / 180.0
      a    = Math::sin(dlat/2.0) ** 2 +
             Math::cos(latitude * Math::PI / 180.0) *
             Math::cos(lat      * Math::PI / 180.0) *
             Math::sin(dlng/2.0) ** 2
      c    = 2.0 * Math::atan2(Math::sqrt(a), Math::sqrt(1.0 - a))

      r * c <= max
    end
  end
end

class Intersection < Place
  def exps
    super + [
      Regexp.new("(?i-mx:#{Regexp.escape main} .*?#{Regexp.escape cross})"),
      Regexp.new("(?i-mx:#{Regexp.escape cross} .*?#{Regexp.escape main})") ]
  end
end

class Address < Place
  def exps
    super + [
      Regexp.new("(?i-mx:#{Regexp.escape number} .*?#{Regexp.escape street})") ]
  end
end

class Landmark < Place
end

class Event < Place
end

class Unknown < Place
end
