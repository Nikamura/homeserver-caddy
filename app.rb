require_relative "./update_caddyfile.rb"

STDOUT.sync = true

while true
  update_caddyfile
  sleep ENV.fetch("CADDYFILE_GENERATOR_INTERVAL", 60).to_i
end
