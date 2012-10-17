require 'rubygems'
require 'unicorn'

# Usage for this program
def usage
  puts "ruby unicorn_status.rb <path to unix socket> <poll interval in seconds>"
  puts "Polls the given Unix socket every interval in seconds. Will not allow you to drop below 3 second poll intervals."
  puts "Example: ruby unicorn_status.rb /var/run/engineyard/unicorn_appname.sock 10"
end

# Look for required args. Throw usage and exit if they don't exist.
if ARGV.count < 2
  usage
  exit 1
end

# Get the socket and threshold values.
socket = ARGV[0]
threshold = (ARGV[1]).to_i

# Check threshold - is it less than 3? If so, set to 3 seconds. Safety first!
if threshold.to_i < 3
  threshold = 3
end

# Check - does that socket exist?
unless File.exist?(socket)
  puts "Socket file not found: #{socket}"
  exit 1
end

# Poll the given socket every THRESHOLD seconds as specified above.
puts "Running infinite loop. Use CTRL+C to exit."
puts "------------------------------------------"
loop do
  Raindrops::Linux.unix_listener_stats([socket]).each do |addr, stats|
    header = "Active Requests         Queued Requests"
    puts header
    puts stats.active.to_s + stats.queued.to_s.rjust(header.length - stats.active.to_s.length)
    puts "" # Break line between polling intervals, makes it easier to read
  end
  sleep threshold
end