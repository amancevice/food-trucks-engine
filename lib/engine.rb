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

require "engine/version"
require "engine/providers"
require "engine/meal"
require "engine/models/pattern"
require "engine/models/place"
require "engine/models/truck"
require "engine/weekday"

module Engine
  def self.migrate
    migration = ActiveRecord::Migration.new

    migration.create_table :places do |t|
      t.float  :latitude
      t.float  :longitude
      t.string :city
      t.string :cross
      t.string :main
      t.string :name
      t.string :neighborhood
      t.string :number
      t.string :source
      t.string :street
      t.string :type
    end

    migration.create_table :trucks do |t|
      t.string :city
      t.string :name
      t.string :site
      t.string :source
    end

    migration.create_table :patterns do |t|
      t.belongs_to :place
      t.belongs_to :truck
      t.string     :type
      t.string     :value
    end
  end

  class Server < Sinatra::Base
    get '/' do
      content_type :json
      params.symbolize_keys!
      klass  = params[:class]&.constantize
      source = klass&.new(
        endpoint: params[:endpoint],
        city:     params[:city],
        timezone: params[:timezone])
      process(source&.response||[]).to_json
    end

    post '/' do
      content_type :json
      params.symbolize_keys!
      process(JSON.parse(params[:payload]||[])).to_json
    end

    private

    def process payload
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
        args.merge(truck.to_h)
            .merge(place.to_h)
            .merge(source:args[:source])
      end
    end
  end

  class Client
    attr_reader = :host

    def initialize args
      @host = URI.parse args[:host]
    end

    def get args
      params  = args.map{|k,v| "#{k}=#{CGI::escape v.to_s}"}.join '&'
      http    = Net::HTTP.new @host.host, @host.port
      request = Net::HTTP::Get.new "#{@host.request_uri}/?#{params}"
      JSON.parse http.request(request).body
    end

    def post payload
      http    = Net::HTTP.new @host.host, @host.port
      request = Net::HTTP::Post.new @host.request_uri
      request.set_form_data payload:payload.to_json
      JSON.parse http.request(request).body
    end
  end
end