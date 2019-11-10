require 'tempfile'
require 'securerandom'
require_relative '../lib/twilio/api_wrapper_stub.rb'
require_relative '../lib/call_manager.rb'

RSpec.describe "CallManager" do
  before(:each) do
    @twilio_api = spy(Twilio::ApiWrapperStub.new('fake_id', 'fake_token'))
    @file = Tempfile.new('CallManager')
    @file.close
  end

  after(:each) do
    @file.unlink
  end

  def create_sid_file(path, number_of_sids)
    File.open(path, 'w') do |file|
      (1..5).each { file.puts SecureRandom.uuid }
    end
  end

  def count_lines_in_file(path)
    File.open(path, 'r') do |file|
      file.readlines.size
    end
  end

  it "start_calls starts the correct number of calls" do
    call_manager = CallManager.new(@twilio_api)
    call_manager.start_calls('https://someurl.com/file.xml', '18055551212', '18055553434', 5, 2, @file.path)

    expect(@twilio_api).to have_received(:start_call).exactly(5).times
    expect(count_lines_in_file(@file.path)).to eq(5)
  end

  it "end_calls ends the correct number of calls" do
    create_sid_file(@file.path, 5)

    call_manager = CallManager.new(@twilio_api)
    call_manager.end_calls(@file.path)

    expect(@twilio_api).to have_received(:end_call).exactly(5).times
  end
end
