require 'twilio-ruby'

module Twilio
  class ApiWrapper
    def initialize(account_sid, auth_token)
      @client = Twilio::REST::Client.new(account_sid, auth_token)
    end

    def start_call(twiml_url, destination_number, caller_id)
      @client.calls.create(
          url: twiml_url,
          to: destination_number,
          from: caller_id
      )
    end

    def end_call(call_sid)
      @client.calls(call_sid).update(status: 'completed')
    end
  end
end
