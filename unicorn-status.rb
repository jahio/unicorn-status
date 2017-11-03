#!/usr/bin/env ruby
require 'rubygems'
require 'unicorn'

# Usage for this program
def usage
  <<~USAGE
    ./unicorn_status.rb [SOCKETPATH OR PORTNUM] [INTERVAL]

    Polls the given SOCKETPATH or PORTNUM every INTERVAL seconds.
    Warning: The faster the poll interval, the more profoundly negative performance impact you'll have. 
             BE CAREFUL WHEN DOING THIS IN PRODUCTION.

    Arguments:
      SOCKETPATH: Local filesystem path to Unicorn socket
                  Example: /var/run/myapp/unicorn_appname.sock
      PORTNUM:    A port on localhost to which a Unicorn worker is bound
                  Example: 3001
      INTERVAL:   Integer representing number of seconds to wait between polls; acceptable values range 1-10
                  Example: 5 (will sleep 5 seconds between polls for current number of requests in queue)
    Examples:
      ruby unicorn_status.rb /var/run/engineyard/unicorn_appname.sock 10
        Generates output every 10 seconds showing total requests in global queue at that specific polling

      ruby unicorn_status.rb 3001 5
        Polls the queue that the Unicorn worker bound to port 3001 is using every 5 seconds and shows that queue's status
    
    If the final argument (integer) representing the poll interval is missing or exceeds 10, it'll default to 5 second intervals.

  USAGE
end

def port_in_use?(portnum)
  begin
    Socket.tcp("localhost", portnum.to_i, connect_timeout: 1) { return true }
  rescue Errno::ETIMEDOUT
    return false
  end
end

# Look for required args. Throw usage and exit if they don't exist.
(puts usage && exit 1) if ARGV.count < 1

# Set the threshold based on user values. 
threshold = ((ARGV[1] && (1..10).include?(ARGV[1].to_i) ? ARGV[1].to_i : 5 ))

# Subject must be a valid socket (existing file) or a port that's in use
def get_subject
  if File.exist?(ARGV[0].to_s)
    return { socket: ARGV[0].to_s }
  end
  if port_in_use?(ARGV[0].to_i)
    return { port: ARGV[0].to_i }
  end
  return nil
end

def request_socket_stats(socket)
  Raindrops::Linux.unix_listener_stats([socket]).each do |addr, stats|
  header = "Active Requests         Queued Requests"
    puts header
    puts stats.active.to_s + stats.queued.to_s.rjust(header.length - stats.active.to_s.length)
    puts "" # Break line between polling intervals, makes it easier to read
  end
end

def request_port_stats(port)
  Raindrops::Linux.tcp_listener_stats("127.0.0.1:#{port}").each do |addr, stats|
  header = "Active Requests         Queued Requests"
    puts header
    puts stats.active.to_s + stats.queued.to_s.rjust(header.length - stats.active.to_s.length)
    puts "" # Break line between polling intervals, makes it easier to read
  end
end

subject = get_subject

# Primary Control Loop
# Poll the given socket every THRESHOLD seconds as specified above.
puts "Running infinite loop. Use CTRL+C to exit."
puts "------------------------------------------"

if subject[:socket]  
  loop do
    request_socket_stats(subject[:socket])
    sleep threshold
  end
elsif subject[:port]
  loop do
    request_port_stats(subject[:port])
    sleep threshold
  end
end
