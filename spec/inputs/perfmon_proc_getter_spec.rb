# To run: jruby -S bundle exec rspec -fd spec
require "logstash/devutils/rspec/spec_helper"
require_relative '../../lib/logstash/inputs/perfmon_proc_getter.rb'

describe 'UnitTests' do
  describe 'PerfmonProcGetter' do
    
	subject(:getter) { PerfmonProcGetter.new }
	
	describe 'get_tasklist_command' do
	  it 'should be expected command' do
	    result = getter.get_tasklist_command(1234)
		expect(result).to eq 'tasklist /FI "PID eq 1234"'
	  end
	end
	
	describe 'get_typeperf_command' do
	  it 'should be expected command' do
	    result = getter.get_typeperf_command(["test_counter", "test_counter_2"], 1)
		expect(result).to eq 'typeperf "test_counter" "test_counter_2" -si 1'
	  end
	end
	
	describe 'get_all_counters_command' do
	  it 'should be expected command' do
	    result = getter.get_all_counters_command
		expect(result).to eq 'typeperf -q'
	  end
	end
	
  end
end