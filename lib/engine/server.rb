module Engine
  class Server < Sinatra::Base

    private

    def handle_get params
      params.symbolize_keys!
      klass  = params[:class]&.constantize
      source = klass&.new(
        endpoint: params[:endpoint],
        city:     params[:city],
        timezone: params[:timezone])
      source&.response
    end

    def handle_post params
      params.symbolize_keys!
      payload = JSON.parse params[:payload]
      Engine.process(payload).map do |args, place, truck|
        day = Time.parse(args[:start]).strftime '%A'
        Meal.between(start:args[:start], stop:args[:stop]).map do |meal|
          item = args.merge(truck.to_h)
            .merge(place.to_h)
            .merge(source:args[:source], day:day, meal:meal)
          item[:sha1] = Digest::SHA1.hexdigest item.to_s
          item
        end
      end.flatten
    end
  end
end
