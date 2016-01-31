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
        args.merge(truck.to_h)
          .merge(place.to_h)
          .merge(source:args[:source])
      end
    end
  end
end
