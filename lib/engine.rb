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

module Engine
  class Migration < ActiveRecord::Migration
    def change
      create_table :places do |t|
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

      create_table :trucks do |t|
        t.string :city
        t.string :name
        t.string :site
        t.string :source
      end

      create_table :patterns do |t|
        t.belongs_to :place
        t.belongs_to :truck
        t.string     :type
        t.string     :value
      end
    end
  end

  class Server < Sinatra::Base

    private

    def handle_get params
      params.symbolize_keys!
      klass  = params[:class]&.constantize
      source = klass&.new(
        endpoint: params[:endpoint],
        city:     params[:city],
        timezone: params[:timezone])
      Engine.process(source&.response||[]).to_json
    end

    def handle_post params
      params.symbolize_keys!
      Engine.process(JSON.parse(params[:payload]||[])).to_json
    end
  end

  class Client
    attr_reader = :host, :port

    def initialize args
      @host    = args[:host]
      @port    = args[:port]
      @path    = args[:path]
      @timeout = args[:read_timeout]||500
    end

    def get args=nil
      params   = args&.map{|k,v| "#{k}=#{CGI::escape v.to_s}"}&.join '&'
      request  = Net::HTTP::Get.new "#{@path}/?#{params}"
      response = Net::HTTP.start(@host, @port, read_timeout:@timeout) do |http|
         http.request request
      end
      JSON.parse response.body
    end

    def post payload
      http    = Net::HTTP.new @host, @port
      request = Net::HTTP::Post.new @path
      request.set_form_data payload:payload.to_json
      response = Net::HTTP.start(@host, @port, read_timeout:@timeout) do |http|
         http.request request
      end
      JSON.parse response.body
    end
  end

  class << self
    def process payload
      payload.map do |args|
        args.symbolize_keys!
        place = Engine.place args
        truck = Engine.truck args
        args.merge(truck.to_h)
          .merge(place.to_h)
          .merge(source:args[:source])
      end
    end

    def process! payload
      payload.map do |args|
        args.symbolize_keys!
        place = Engine.place args
        truck = Engine.truck args
        place.save
        truck.save
        args.merge(truck.to_h)
          .merge(place.to_h)
          .merge(source:args[:source])
      end
    end


    def place args
      Place.match(
        city:      args[:city],
        name:      args[:place],
        latitude:  args[:latitude],
        longitude: args[:longitude],
        source:    args[:source],
        dist:      args[:dist])
    end

    def truck args
      Truck.match(
        city:   args[:city],
        name:   args[:truck],
        site:   args[:site],
        source: args[:source])
    end
  end
end
