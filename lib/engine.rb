#require "active_support/time"
require "chronic"
require "geocoder"
require "geocoder/railtie"
require "json"
require "json"
require "oga"
require "sinatra"
require "sinatra/activerecord"

Geocoder::Railtie.insert

require "engine/client"
require "engine/like"
require "engine/locatable"
require "engine/meal"
require "engine/migration"
require "engine/pattern"
require "engine/place"
require "engine/server"
require "engine/source"
require "engine/truck"
require "engine/version"

module Engine
  def self.process payload, send:nil
    payload.map do |args|
      args.symbolize_keys!
      place = Place.match(
        city:      args[:city],
        name:      args[:place],
        latitude:  args[:latitude],
        longitude: args[:longitude],
        source:    args[:source],
        dist:      args[:dist])
      truck = Truck.match(
        city:   args[:city],
        name:   args[:truck],
        site:   args[:site],
        source: args[:source])
      if send
        place.send send
        truck.send send
      end
      day = Time.parse(args[:start]).strftime '%A'
      Meal.between(start:args[:start], stop:args[:stop]).map do |meal|
        item = args.merge(truck.to_h)
          .merge(place.to_h)
          .merge(source:args[:source], weekday:day, meal:meal)
        item[:sha1] = Digest::SHA1.hexdigest item.to_s
        item
      end
    end.flatten
  end

  def self.process! payload
    process payload, send: :save!
  end
end
