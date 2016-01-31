module Engine
  class Client
    attr_reader :host, :port

    def initialize host:"localhost", port:nil
      @host = host
      @port = port
    end

    def get path:nil, read_timeout:nil, **params
      params&.map!{|k,v| "#{k}=#{CGI::escape v.to_s}"}&.join "&"
      request  = Net::HTTP::Get.new "#{path||"/"}?#{params}"
      response = Net::HTTP.start(@host, @port, read_timeout:read_timeout) do |http|
        http.request request
      end
      json = JSON.parse(response.body).symbolize_keys
      json[:response].collect(&:symbolize_keys)
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
