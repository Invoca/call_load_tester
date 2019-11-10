require_relative 'rate_limiter'

class CallManager
  def initialize(twilio_api)
    @twilio_api = twilio_api
  end

  def start_calls(twiml_url, destination_number, caller_id, call_count, call_starts_per_second, call_sids_file_name)
    puts "Creating #{call_count} calls from #{caller_id} to #{destination_number} with call treatment #{twiml_url}"
    puts "Writing call SIDs to #{call_sids_file_name}"
    File.open(call_sids_file_name, 'w') do |file|
      rate_limiter(call_count, call_starts_per_second, 'CPS') do |call_index|
        call = @twilio_api.start_call(twiml_url, destination_number, caller_id)
        file.puts(call.sid)
        puts("Started call #{call_index + 1}. SID: #{call.sid}")
      end
    end
  end

  def end_calls(call_sids_file_name)
    File.readlines(call_sids_file_name, chomp: true).each_with_index do |call_sid, call_index|
      puts "Ending call #{call_index + 1}. SID: #{call_sid}"
      @twilio_api.end_call(call_sid)
    rescue => ex
      puts "Failed to end call SID #{call_sid} because #{ex.class} #{ex.message}"
    end
  end
end
