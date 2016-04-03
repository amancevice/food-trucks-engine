module EaterAtlas
  module Helper
    def self.source args
      args[:class]&.constantize&.new(args.slice(:city, :timezone, :endpoint)).response
    end

    def self.place args
      args = args.slice :city, :place, :latitude, :longitude, :source, :timezone, :dist
      [Place.match(args).attributes.symbolize_keys.merge(type:"Place")]
    end

    def self.truck args
      args = args.slice :city, :truck, :site, :source
      [Truck.match(args).attributes.symbolize_keys.merge(type:"Truck")]
    end

    def self.gigs args
      pargs = args.slice :city, :place, :latitude, :longitude, :source, :timezone, :dist
      targs = args.slice :city, :truck, :site, :source
      place = Place.match pargs
      truck = Truck.match targs
      day   = Time.parse(args[:start]).in_time_zone(args[:timezone]).strftime '%A'
      keys  = [
        :city, :endpoint, :id, :latitude, :longitude, :meal, :neighborhood,
        :place, :site, :source, :start, :stop, :timezone, :truck, :weekday]
      items = Meal.between(args.slice(:start, :stop, :timezone)).map do |meal|
        item = args.merge(truck.attributes.symbolize_keys.reject{|k,v| v.nil? })
          .merge(place.attributes.symbolize_keys.reject{|k,v| v.nil? })
          .merge(source:args[:source], weekday:day, meal:meal)
        item.merge id:Digest::SHA1.hexdigest(item.to_s), type:"Gig"
      end.map{|x| x.slice(*keys) }
    end

    def self.update args
      pargs = args.slice :city, :place, :latitude, :longitude, :source, :timezone, :dist
      targs = args.slice :city, :truck, :site, :source
      place = Place.match pargs
      truck = Truck.match targs
      place.save
      truck.save
    end

    def self.firedata gigs
      # Format data for Firebase
      gigs.map do |gig|
        { gig[:weekday] =>
          { gig[:meal] =>
            { gig[:id] => gig.except(:id, :geoname, :type) }}}
      end.reduce &:deep_merge
    end

    def self.firebase args
      gen = Firebase::FirebaseTokenGenerator.new args[:secret]
      tkn = gen.create_token args.slice(:user)
      Bigbertha::Ref.new args[:firebase], tkn
    end
  end
end