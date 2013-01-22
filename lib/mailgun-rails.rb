require "action_mailer"
require "active_support"
require "curb"

module Mailgun

  class DeliveryError < StandardError
  end

  class DeliveryMethod

    attr_accessor :settings

    def initialize(settings)
      self.settings = settings
    end

    def api_host
      self.settings[:api_host]
    end

    def api_key
      self.settings[:api_key]
    end

    def deliver!(mail)

      body              = Curl::PostField.content("message", mail.encoded)
      body.remote_file  = "message"
      body.content_type = "application/octet-stream"

      data = []
      data << body

      mail.destinations.each do |destination|
        data << Curl::PostField.content("to", destination)
      end

      curl                     = Curl::Easy.new("https://api:#{self.api_key}@api.mailgun.net/v2/#{self.api_host}/messages.mime")
      curl.ssl_verify_peer = false
      curl.multipart_form_post = true
      curl.http_post(*data)

      if curl.response_code != 200

        begin
          error = ActiveSupport::JSON.decode(curl.body_str)["message"]
        rescue
          error = "Unknown Mailgun Error"
        end

        raise Mailgun::DeliveryError.new(error)
      end

    end


  end

end

ActionMailer::Base.add_delivery_method :mailgun, Mailgun::DeliveryMethod

