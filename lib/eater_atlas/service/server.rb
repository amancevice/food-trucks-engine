module EaterAtlas
  class Server < Sinatra::Base
    configure do
      set :firebase, ENV['FIREBASE_HOME']
      set :secret,   ENV['FIREBASE_SECRET']
      set :user,     ENV['FIREBASE_USER']
    end

    get '/' do
      content_type :json
      json firebase.val
    end

    get '/privacy' do
      "EaterAtlas does not share any information about its users with outside parties."
    end

    get '/source' do
      content_type :json
      params.symbolize_keys!

      json begin
        { meta:params, data:EaterAtlas::Helper.source(params) }
      rescue NameError => e
        { meta:params, errors:[e.message] }
      rescue SocketError => e
        { meta:params, errors:[e.message] }
      end
    end

    get '/:helper' do |helper|
      content_type :json
      params.symbolize_keys!

      json meta:params, data:EaterAtlas::Helper.send(helper.to_sym, params)
    end

    post '/' do
      content_type :json
      params.symbolize_keys!

      payload = begin
        keys = [
          :city, :endpoint, :latitude, :longitude, :place, :site, :source,
          :start, :stop, :timezone, :truck, :neighborhood, :weekday, :meal]
        JSON.parse(params[:payload]).map do |x|
          x.symbolize_keys!
          { x[:id] => x.slice(*keys) }
        end.reduce &:merge
      end

      firebase.set payload

      json({meta:{}, data:[]})
    end

    private

    def firebase
      @ref ||= EaterAtlas::Helper.firebase(
        firebase: settings.firebase,
        secret:   settings.secret,
        user:     settings.user)
    end
  end
end
