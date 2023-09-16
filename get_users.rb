require "pg"
require "json"

def get_users
  postgres_creds = URI.parse("postgres://" + ENV.fetch("POSTGRES_URL"))

  conn = PG.connect({ host: postgres_creds.host, dbname: postgres_creds.path[1..-1], user: postgres_creds.user, password: postgres_creds.password, port: postgres_creds.port })

  conn.exec("SELECT user_email, user_role FROM users ORDER BY user_email ASC") do |result|
    result.map { |res| res.values_at("user_email", "user_role") }.to_h
  end
ensure
  conn.close
end
