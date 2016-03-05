module Engine
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
      items = Meal.between(args.slice(:start, :stop, :timezone)).map do |meal|
        item = args.merge(truck.attributes.symbolize_keys)
          .merge(place.attributes.symbolize_keys)
          .merge(source:args[:source], weekday:day, meal:meal)
        item.merge id:Digest::SHA1.hexdigest(item.to_s), type:"Gig"
      end.map{|x| x.slice(*args.keys).except(:dist) }
    end

    def self.firebase args
      gen = Firebase::FirebaseTokenGenerator.new args[:secret]
      tkn = gen.create_token args.slice(:user)
      Bigbertha::Ref.new args[:firebase], tkn
    end
  end
end