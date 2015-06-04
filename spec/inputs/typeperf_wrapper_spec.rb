# To run: jruby -S bundle exec rspec -fd spec
require "logstash/devutils/rspec/spec_helper"
require_relative '../../lib/logstash/inputs/typeperf_wrapper.rb'

describe 'TypeperfWrapper' do
  subject(:wrapper) { TypeperfWrapper.new }
  
  describe 'initialize' do
    it 'should initialize the counters array to empty' do
	  expect(wrapper.counters).to be_empty
    end
  end
  
  describe 'add_counter' do
    it 'should add a counter to the array' do
      wrapper.add_counter '\\processor(_total)\\% processor time'
	  expect(wrapper.counters.count).to eq 1
    end
	
	it 'should convert the counter name to lowercase' do
	  wrapper.add_counter '\\Processor(_total)\\% Processor Time'
	  expect(wrapper.counters[0]).to eq '\\processor(_total)\\% processor time'
	end
  end
  
  describe 'start_monitor' do
    it 'should raise error if no counters are defined' do
	  expect { wrapper.start_monitor }.to raise_error('No perfmon counters defined')
	end
	
	it 'should start the process running' do
	  wrapper.add_counter '\\Processor(_total)\\% Processor Time'
	  wrapper.start_monitor
	  expect(wrapper.alive?).to eq true
	  wrapper.stop_monitor
	end
  end
  
  describe 'stop_monitor' do
    it 'should stop the monitor thread' do
	  wrapper.add_counter '\\Processor(_total)\\% Processor Time'
	  wrapper.start_monitor
	  wrapper.stop_monitor
	  expect(wrapper.alive?).to eq false
	end
  end
  
  describe 'alive?' do
    it 'is false when monitor has not been started' do
	  expect(wrapper.alive?).to eq false
	end
  end

end