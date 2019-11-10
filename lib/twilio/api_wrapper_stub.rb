require 'securerandom'

module Twilio
  class CallStub
    attr_reader :sid

    def initialize
      @sid = SecureRandom.uuid
    end
  end

  class ApiWrapperStub
    def initialize(account_sid, auth_token)
    end

    def start_call(twiml_url, destination_number, caller_id)
      sleep(rand()/10)
      CallStub.new
    end

    def end_call(call_sid)
    end
  end
end
