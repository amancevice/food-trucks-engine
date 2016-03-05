module Engine
  class Client
    attr_reader :host, :port

    def initialize host:"localhost", port:9292
      @host = host
      @port = port
    end

    def get path:nil, **params
      params   = params&.map{|k,v| "#{k}=#{CGI::escape v.to_s}"}&.join "&"
      request  = Net::HTTP::Get.new "#{path||"/"}?#{params}"
      response = Net::HTTP.start(@host, @port){|http| http.request request }

      json = JSON.parse(response.body).symbolize_keys
      json[:meta].symbolize_keys!
      json[:data].map &:symbolize_keys!

      json
    end

    def gigs path:"/source", **params
      response = get path:path, **params
      data = response[:data]||[]
      data.map{|x| get path:"/gigs", **x }.map{|x| x[:data]||[] }.flatten
    end

    def post payload:nil
      http    = Net::HTTP.new @host, @port
      request = Net::HTTP::Post.new "/"
      request.set_form_data payload:payload&.to_json
      response = Net::HTTP.start(@host, @port){|http| http.request request }

      json = JSON.parse(response.body).symbolize_keys
      json[:meta].symbolize_keys!
      json[:data].map &:symbolize_keys!

      json
    end
  end
end
