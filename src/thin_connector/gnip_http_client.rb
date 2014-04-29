require 'rest-client'

module ThinConnector

  class GnipHTTPClient

    def initialize
      @logger = ThinConnector::Logger.new
    end

    def get(url, headers=nil, params=nil)
      method = :get
      make_request method, url, { headers: headers, params: params }
    end

    def put(url, headers=nil, params=nil)
      method = :put
      make_request method, url, { headers: headers, params: params }
    end

    def post(url, headers=nil, params=nil)
      method = :post
      make_request method, url, { params: headers, headers: params }
    end

    def delete(url, headers=nil, params=nil)
      method = :delete
      make_request method, url, { headers: headers, params: params }
    end

    private

    def default_headers
      auth_header
    end

    def auth_header; { authorization: [environment.gnip_username, environment.gnip_password] }; end

    def make_request(action, url, options={})
      @logger.info "Making request with options #{[action, url, options].inspect}"
      headers = options[:headers] || default_headers
      params = options[:params] || {}
      payload = headers.merge params
      RestClient.send action, url, payload
    end

    def environment; ThinConnector::Environment.instance; end

  end
end