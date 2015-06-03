# Wraps the typeperf command-line tool, used to get 
# Windows performance metrics
class TypeperfWrapper
  attr_reader :counters
  
  # Initializes the TypeperfWrapper class
  def initialize
    @counters = []
  end
  
  # Adds a counter to the list of counters watched
  # [counter_name] The path to the counter, such as "\\processor(_total)\\% processor time"
  def add_counter(counter_name)
    @counters << counter_name.downcase!
  end
  
  # Begins monitoring, using the counters in the @counters array
  # [interval] The time between samples, defaults to ten seconds
  def start_monitor(interval = 10)
    raise "No counters defined" if @counters.empty?
	
    # spawn the typeperf process with the counters 
	# and defined interval
    @pid = spawn(
	  'typeperf', 
	  *@counters, 
	  '-si', interval.to_s)
	
	# don't wait for the termination status
	Process.detach(@pid) 
  end
  
  # Stops monitoring
  def stop_monitor
	Process.kill(9, @pid)
  end
  
  # Gets a value indicating whether the process is alive and running
  def alive?
    return false if @pid.nil?
	
	begin
      Process.kill(0, @pid)
      return true
    rescue Errno::EPERM      
      return false
    rescue Errno::ESRCH
	  return false
    rescue
      raise "Unable to determine status for #{@pid} : #{$!}"
    end
  end
end