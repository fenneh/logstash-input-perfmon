class PerfmonProcGetter
  attr_reader :pid
  
  def initialize
    @all_counters = `#{get_all_counters_command}`
  end
  
  def start_process(counters, interval, output_queue)
	cmd = get_typeperf_command(counters, interval)
	  
	IO.popen(cmd) do |f|
      @pid = f.pid

      f.each do |line| 
		next if counters.any? { |counter| line.include? counter } # don't show lines that contain headers
        output_queue << line
      end
    end
  end
  
  def stop_process
    Process.kill(9, @pid) 
	@pid = nil
  end
  
  def proc_is_running?
    if @pid.nil?
	  return false
	else
	  return true
	end
  end
  
  def counter_exists?(counter_name)
    counter_name = counter_name.gsub(/\(.+\)/, '(*)')
	return @all_counters.include?(counter_name)
  end
  
  def get_typeperf_command(counters, interval)
    cmd = "typeperf "
    counters.each { |counter| cmd << "\"#{counter}\" " }
    cmd << "-si #{interval.to_s} "
    return cmd.strip!
  end
  
  def get_tasklist_command(pid)
    "tasklist /FI \"PID eq #{pid}\""
  end
  
  def get_all_counters_command
    "typeperf -q"
  end
  
  def wait_for_process_to_start
    sleep 0.5 until proc_is_running?
  end
end