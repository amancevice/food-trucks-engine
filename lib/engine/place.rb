class Place < ActiveRecord::Base
  include Like, Locatable
  @@cache = {}
  has_many :patterns, class_name:"PlacePattern"
  validates :name, :city, :latitude, :longitude, presence: true
  validates :name, uniqueness: {scope: :city}
  before_validation :geocache
  before_create :default_patterns
  geocoded_by :long_name
  reverse_geocoded_by :latitude, :longitude, address: :name
  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :nearby, -> args { where id:select{|x| x.nearby? args }.collect(&:id) }
  scope :match, -> args {
    places = args[:city].nil? ? Place.all : Place.where(city:args[:city])
    places.like(args[:name]).first ||
      places.nearby(lat:args[:latitude], lng:args[:longitude], max:args[:dist]||0.05).first ||
      places.near("#{args[:name]} #{args[:city]}".strip, args[:dist]||0.05, units: :km).first ||
      Unknown.new(
        city:      args[:city],
        name:      args[:name],
        latitude:  args[:latitude],
        longitude: args[:latitude],
        source:    args[:source])
  }

  def geocache
    @@cache[long_name] ||= (latitude.nil?||longitude.nil?) ? geocode : [latitude, longitude]
  end

  def long_name
    @long_name ||= "#{name} #{city}"
  end

  def to_h
    { city:         city,
      place:        name,
      neighborhood: neighborhood,
      latitude:     latitude,
      longitude:    longitude,
      source:       source,
      type:         type }.reject{|k,v| v.nil? }
  end
end

class Intersection < Place
  def default_patterns
    super + [ patterns.new(value:"(?i-mx:#{Regexp.escape self.main} .*? #{Regexp.escape self.cross})"),
              patterns.new(value:"(?i-mx:#{Regexp.escape self.cross} .*? #{Regexp.escape self.main})") ]
  end
end

class Address < Place
  def default_patterns
    super + [ patterns.new(value:"(?i-mx:#{Regexp.escape number} .*?#{Regexp.escape street})") ]
  end
end

class Landmark < Place
end

class Event < Place
end

class Unknown < Place
end
