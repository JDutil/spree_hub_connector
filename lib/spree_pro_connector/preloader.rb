require 'httparty'

module SpreeProConnector
  class PreloadError < Exception; end

  class Preloader
    include HTTParty

    attr_accessor :base_url, :store_id, :api_key

    def initialize(base_url, store_id, api_key)
      self.class.base_uri "#{base_url}/api"
      @store_id = store_id
      @api_key = api_key
    end

    def messages
      response = self.class.get("/stores/#{@store_id}/available_messages", default_headers)
      check_response response
    end

    def global_integrations
      response = self.class.get("/stores/#{@store_id}/integrations?global=1", default_headers)
      check_response response
    end

    def store_integrations
      response = self.class.get("/stores/#{@store_id}/integrations", default_headers)
      check_response response
    end

    def mappings
      response = self.class.get("/stores/#{@store_id}/mappings", default_headers)
      check_response response
    end

    def schedulers
      response = self.class.get("/stores/#{@store_id}/schedulers", default_headers)
      check_response response
    end

    def parameters
      response = self.class.get("/stores/#{@store_id}/parameters", default_headers)
      check_response response
    end

    private

    def default_headers
      { :headers => { "X-Augury-Token" => @api_key } }
    end

    def check_response(response)
      case response.code
      when 200
        response.to_json
      else
        raise PreloadError
      end
    end
  end
end
