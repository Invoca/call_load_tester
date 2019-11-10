require 'optparse'
require 'ostruct'
require_relative 'lib/twilio/api_wrapper'
require_relative 'lib/twilio/api_wrapper_stub'
require_relative 'lib/call_manager'

def parse_options
  options = OpenStruct.new
  options.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  options.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
  option_parser = OptionParser.new do |opt|
    opt.on('-f', '--file FILE_PATH', 'Path to a file containing the call SIDs to end') { |o| options.call_sids_file_name = o }
    opt.on('--sid SID', 'Twilio account SID. Recommend using ENV variable TWILIO_ACCOUNT_SID instead of command line argument.') { |o| options.twilio_account_sid = o }
    opt.on('--token TOKEN', 'Twilio API authorization token. Recommend using ENV variable TWILIO_AUTH_TOKEN instead of command line argument') { |o| options.twilio_auth_token = o }
  end
  option_parser.parse!

  unless options.twilio_account_sid && \
      options.twilio_auth_token && \
      options.call_sids_file_name
    option_parser.summarize(STDOUT)
    nil
  else
    options
  end
end

if options = parse_options
  call_manager = CallManager.new(Twilio::ApiWrapper.new(options.twilio_account_sid, options.twilio_auth_token))
  call_manager.end_calls(options.call_sids_file_name)
end
