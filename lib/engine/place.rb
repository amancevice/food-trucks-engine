class Place < ActiveRecord::Base
  include Like
  @@cache = {}
  has_many :patterns, class_name:"PlacePattern"
  validates :name, :city, :latitude, :longitude, presence: true
  validates :name, uniqueness: {scope: :city}
  before_validation :geocache
  before_create :default_patterns
  geocoded_by :long_name
  reverse_geocoded_by :latitude, :longitude, address: :name
  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :match, -> args {
    # Places in a city
    places = Place.where city:args[:city]
    # Find Place like or near
    lname = "#{args[:name]} #{args[:city]}".strip
    dist  = args[:dist] || 0.025
    place = (places.like(args[:name]) || places.near(lname, dist, order:'distance')).first
    # Create an Unknown place otherwise
    place ||= Unknown.new(
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
