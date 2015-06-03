# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "socket" # for Socket.gethostname
require_relative "typeperf_wrapper"

# Generates logs for Windows Performance Monitor
class LogStash::Inputs::Perfmon < LogStash::Inputs::Base
  config_name "perfmon"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain" 

  # Set how frequently metrics should be gathered
  config :interval, :validate => :number, :default => 10

  #------------Public Methods--------------------
  public
  
  def register
    @host = Socket.gethostname
	@typeperf = TypeperfWrapper.new
  end

  # Runs the perf monitor and monitors its output
  def run(queue)
    @typeperf.start_monitor
	data = $stdout.sysread(16384)
	@codec.decode(data) do |event|
      decorate(event)
      queue << event
	end
  end 

  # Cleans up any resources
  def teardown
    @logger.debug("Stopping the perfmon monitor")
    @typeperf.stop_monitor
	@logger.debug("Perfmon monitor shutdown? #{@typeperf.alive?}")
	finished
  end
end