require_relative "./update_caddyfile.rb"

STDOUT.sync = true

while true
  begin
    update_caddyfile
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace
  end
  sleep ENV.fetch("CADDYFILE_GENERATOR_INTERVAL", 60).to_i
end
