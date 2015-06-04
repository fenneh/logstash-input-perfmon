require 'win32/process'

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
    raise "No perfmon counters defined" if @counters.empty?
	
    cmd = get_typeperf_command(@counters, interval)
	
    @t1 = Thread.new do
      IO.popen(cmd) do |f|
        @pid = f.pid

        f.each do |line| 
          puts line
        end
      end
    end
	
    wait_for_pid_to_be_assigned()
  end
  
  # Stops monitoring
  def stop_monitor
    Process.kill(9, @pid) 
  end
  
  # Gets a value indicating whether the typeperf process is running
  def alive?
    return false if @pid.nil?
  
    result = `#{get_tasklist_command(@pid)}`

    return false if result.nil?
    return false if result =~ /No tasks are running which match the specified criteria/
    return true
  end
  
  #-------------Private methods----------------
  private
  
  def get_typeperf_command(counters, interval)
    cmd = "typeperf "
    counters.each { |counter| cmd << "\"#{counter}\" " }
    cmd << "-si #{interval.to_s} "
    return cmd
  end
  
  def get_tasklist_command(pid)
    "tasklist /FI \"PID eq #{pid}\""
  end
  
  def wait_for_pid_to_be_assigned
    5.times do
      break if @pid != nil
      sleep 1
    end
  end
end