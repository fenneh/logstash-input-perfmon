require "logstash/devutils/rspec/spec_helper"
require_relative '../../lib/logstash/inputs/perfmon'

describe 'IntegrationTests' do
  describe 'Perfmon' do
  
    subject(:plugin) do
	  LogStash::Inputs::Perfmon.new(
		  "interval" => 1,
		  "counters" => ["\\Processor(_Total)\\% Processor Time"]
		)
	end
  
    describe 'initialize' do
      it 'assigns counters and interval' do
		expect(plugin.counters).to eq ["\\Processor(_Total)\\% Processor Time"]
		expect(plugin.interval).to eq 1
	  end
    end
	
	describe 'run' do
	  it 'starts listening for perf metrics' do
	    my_queue = Queue.new
		
		plugin.register
		
		Thread.new do
		  plugin.run(my_queue)
		end
		
		# It can take a few seconds for it to start collecting metrics
		# Wait up to 60 seconds
		60.times do
		  break unless my_queue.empty?
		  sleep 1
		end
		
		expect(my_queue).not_to be_empty
		
		plugin.teardown
	  end
	end
	
  end
end