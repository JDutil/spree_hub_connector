module Spree::Admin
  class EndpointMessage < ActiveRecord::Base
    self.table_name = "spree_endpoint_messages"

    delegate :code, :body, :headers, to: :response, prefix: true

    validates :payload    , presence: true , json: true
    validates :uri        , presence: true
    validates :token      , presence: true
    validates :parameters , json: true

    attr_accessible :message, :uri, :token, :payload, :parameters

    def uri=uri
      uri = "http://#{uri}" if !uri.blank? && !uri.match(/^https?:\/\//)
      write_attribute :uri, uri
    end

    def payload=payload
      write_attribute :payload, payload
      payload_hash = JSON.parse payload
      add_message_id(payload_hash) if payload_hash["message_id"].blank?
      write_attribute :message_id, payload_hash["message_id"]
      write_attribute :message,    payload_hash["message"]
      write_attribute :payload,    JSON.pretty_generate(payload_hash)
    rescue JSON::ParserError
    end

    def send_request request_client=ApiRequest
      return unless valid?
      write_attribute :response_data, request_client.post(token, uri, full_payload)
      save
    end

    def response_headers
      response_data[:headers]
    end

    def response_code
      response_data[:code]
    end

    def response_body
      response_data[:body]
    end

    private :save, :create

    private

    def parameters_hash
      JSON.parse parameters unless parameters.blank?
    end

    def add_message_id target_hash
      target_hash["message_id"] = BSON::ObjectId.new.to_s
    end

    def full_payload
      JSON.parse(payload).merge(parameters_hash || {}).to_json
    end
  end
end

