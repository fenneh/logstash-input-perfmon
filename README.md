# Perfmon Logstash Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

On Windows, performance metrics can be collected using [Windows Performance Monitor](https://technet.microsoft.com/en-us/library/cc749249.aspx).
This plugin collects the same sort of counters by using the command-line tool [Typeperf](https://technet.microsoft.com/en-us/library/bb490960.aspx).

To run the tests (be sure that JRuby is installed prior):
```
git clone https://github.com/NickMRamirez/logstash-input-perfmon.git
cd logstash-input-perfmon
jruby -S bundle install
jruby -S bundle exec rspec spec
```

To build the gem:
```
git clone https://github.com/NickMRamirez/logstash-input-perfmon.git
cd logstash-input-perfmon
gem build logstash-input-perfmon.gemspec
```

To install the gem to logstash:
```
cd path\to\logstash\bin
plugin install path\to\gem
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

filter {
  grok {
	match => {
	  "message" => "%{DATESTAMP:Occurred},%{NUMBER:PrivilegedTime:float},%{NUMBER:ProcessorTime:float},%{NUMBER:UserTime:float}"
	}
  }
}

output {
  file {
	path => "C:\perfmon_output.txt"
  }
}
```

This configuration will produce output like:
```
{
  "message":"06/05/2015 15:40:46.999,0.781236,7.032877,6.249891",
  "@version":"1",
  "@timestamp":"2015-06-05T19:40:48.468Z",
  "Occurred":"06/05/2015 15:40:46.999",
  "PrivilegedTime":0.781236,
  "ProcessorTime":7.032877,
  "UserTime":6.249891
}
```

Run logstash:
```
    logstash -f C:\path\to\conf
```