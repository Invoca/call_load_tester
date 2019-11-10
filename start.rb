require 'optparse'
require 'ostruct'
require_relative 'lib/twilio/api_wrapper'
require_relative 'lib/twilio/api_wrapper_stub'
require_relative 'lib/call_manager'

def true?(obj)
  ['1', 'true', 'yes', 'Y'].include?(obj.to_s.downcase)
end

def parse_options
  options = OpenStruct.new
  options.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  options.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
  options.dry_run = false
  options.call_sids_file_name = "call_sids_#{Time.now.to_i}.csv"
  options.end_calls = true
  options.hold_seconds = 0
  option_parser = OptionParser.new do |opt|
    opt.on('-c', '--caller_id PHONE_NUMBER', 'The caller ID to use for the calls') { |o| options.caller_id = o }
    opt.on('-d', '--destination PHONE_NUMBER', 'The number to call.') { |o| options.destination_number = o }
    opt.on('--call_count NUMBER', 'The number of calls to start.') { |o| options.call_count = o.to_i }
    opt.on('--cps NUMBER', 'Maximum number of calls to start per second.') { |o| options.cps = o.to_i }
    opt.on('-t', '--twiml URL', 'The URL for the Twillio Markup Language that controls the call behavior.') { |o| options.twiml_url = o }
    opt.on('--dry_run', '') { |o| options.dry_run = true?(o) }
    opt.on('-e', '--end_calls BOOLEAN') { |o| options.end_calls = true?(o) }
    opt.on('-h', '--hold SECONDS', 'Number of seconds to wait before hanging up the calls.') { |o| options.hold_seconds = o.to_i }
    opt.on('--sid SID', 'Twilio account SID. Recommend using ENV variable TWILIO_ACCOUNT_SID instead of command line argument.') { |o| options.twilio_account_sid = o }
    opt.on('--token TOKEN', 'Twilio API authorization token. Recommend using ENV variable TWILIO_AUTH_TOKEN instead of command line argument') { |o| options.twilio_auth_token = o }
  end
  option_parser.parse!

  unless options.twilio_account_sid && \
      options.twilio_auth_token && \
      options.caller_id && \
      options.destination_number && \
      options.call_count > 0 && \
      options.cps > 0 && \
      options.twiml_url
    option_parser.summarize(STDOUT)
    nil
  else
    options
  end
end

if options = parse_options
  twilio_api = if options.dry_run
                 puts 'DRY RUN. Actual calls will not be placed.'
                 Twilio::ApiWrapperStub.new(options.twilio_account_sid, options.twilio_auth_token)
               else
                 Twilio::ApiWrapper.new(options.twilio_account_sid, options.twilio_auth_token)
               end
  call_manager = CallManager.new(twilio_api)
  call_manager.start_calls(
      options.twiml_url,
      options.destination_number,
      options.caller_id,
      options.call_count,
      options.cps,
      options.call_sids_file_name
  )
  if options.end_calls
    if options.hold_seconds > 0
      puts "Waiting #{options.hold_seconds} seconds before ending calls"
      sleep(options.hold_seconds)
    end
    call_manager.end_calls(options.call_sids_file_name)
  end
end
