class PerfmonProcGetter
  attr_reader :pid
  
  def start_process(counters, interval, output_queue)
	cmd = get_typeperf_command(counters, interval)
	  
	IO.popen(cmd) do |f|
      @pid = f.pid

      f.each do |line| 
        output_queue << line
      end
    end
  end
  
  def stop_process
    Process.kill(9, @pid) 
  end
  
  def proc_is_running?
    return false if @pid.nil?
  
    result = `#{get_tasklist_command(@pid)}`

    return false if result.nil?
    return false if result =~ /No tasks are running which match the specified criteria/
    return true
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
  
  def wait_for_process_to_start
    sleep 0.5 until proc_is_running?
  end
end