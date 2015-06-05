# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "socket" # for Socket.gethostname
require_relative "typeperf_wrapper"

# Generates logs for Windows Performance Monitor
class LogStash::Inputs::Perfmon < LogStash::Inputs::Base
  attr_reader :counters, :interval
  
  config_name "perfmon"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain" 
  
  # Sets which perfmon counters to collect
  config :counters, :validate => :array, :required => false, :default => [
    "\\Processor(_Total)\\% Processor Time",
    "\\Processor Information(_Total)\\% User Time", 
    "\\Process(_Total)\\% Privileged Time"]

  # Sets the frequency, in seconds, at which to collect perfmon metrics
  config :interval, :validate => :number, :required => false, :default => 10
  
  #------------Public Methods--------------------
  public
  
  def register
	@host = Socket.gethostname
	@typeperf = TypeperfWrapper.new(PerfmonProcGetter.new, @interval)
	@counters.each { |counter| @typeperf.add_counter(counter) }
  end

  # Runs the perf monitor and monitors its output
  def run(queue)
    @typeperf.start_monitor
	
	@logger.debug("Started perfmon monitor")

	while @typeperf.alive?
	  data = @typeperf.get_next

	  @codec.decode(data) do |event|
        decorate(event)
        queue << event
		@logger.debug("Added event to queue: #{event}")
	  end
	end
  end 

  # Cleans up any resources
  def teardown
    @typeperf.stop_monitor
	@logger.debug("Stopped the perfmon monitor")
	finished
  end

end