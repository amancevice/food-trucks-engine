module Engine
  class Client
    attr_reader :host, :port

    def initialize host:"localhost", port:nil
      @host = host
      @port = port
    end

    def query path:nil, read_timeout:nil, **params
      payload  = get path:path, read_timeout:read_timeout, **params
      response = post path:path, read_timeout:read_timeout, payload:payload
      response[:response]&.collect &:symbolize_keys
    end

    def get path:nil, read_timeout:nil, **params
      params   = params&.map{|k,v| "#{k}=#{CGI::escape v.to_s}"}&.join "&"
      request  = Net::HTTP::Get.new "#{path||"/"}?#{params}"
      response = Net::HTTP.start(@host, @port, read_timeout:read_timeout) do |http|
        http.request request
      end
      json = JSON.parse(response.body).symbolize_keys
      json[:response]&.collect &:symbolize_keys
    end

    def post path:nil, read_timeout:nil, payload:nil
      http    = Net::HTTP.new @host, @port
      request = Net::HTTP::Post.new path||"/"
      request.set_form_data payload:payload&.to_json
      response = Net::HTTP.start(@host, @port, read_timeout:read_timeout) do |http|
        http.request request
      end
      JSON.parse(response.body).symbolize_keys
    end
  end
end