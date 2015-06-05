# Perfmon Logstash Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

On Windows, performance metrics can be collected using [Windows Performance Monitor](https://technet.microsoft.com/en-us/library/cc749249.aspx).
This plugin collects the same sort of counters by using the command-line tool [Typeperf](https://technet.microsoft.com/en-us/library/bb490960.aspx).

To build the gem:
```
    git clone https://github.com/NickMRamirez/logstash-input-perfmon.git
	cd logstash-input-perfmon
    gem build logstash-input-perfmon.gemspec
```
	
To install the gem to logstash:
```
    cd path\to\logstash
    bin/plugin install path\to\gem
```
	
Create a configuration file. The following collects three metrics every ten seconds:
```ruby
    input {
      perfmon {
        interval => 10 
          counters => [
            "\Processor(_Total)\% Privileged Time",
            "\Processor(_Total)\% Processor Time", 
            "\Processor(_Total)\% User Time"]
      }
    }

    output {
      file {
        path => "C:\perfmon_output.txt"
      }
    }
```