require_relative "./get_users.rb"

def update_caddyfile
  caddy_file_path = ENV.fetch("CADDY_FILE_PATH").freeze
  puts "Updating Caddyfile at #{caddy_file_path}"

  if (caddy_file_path.nil? || caddy_file_path.empty?) 
    puts "CADDY_FILE_PATH is not set, skipping Caddyfile update"
    return
  end

  if !File.exist?(caddy_file_path)
    puts "Caddyfile does not exist at #{caddy_file_path}, creating Caddyfile"
    File.write(caddy_file_path, File.read("./Caddyfile.template"))
  end

  caddyfile = File.read(caddy_file_path)

  roles_map = {
    "basic" => ["authp/user", "dev/user"].join(" "),
    "advanced" => ["authp/user", "authp/advanced", "dev/user", "dev/advanced"].sort.join(" "),
    "admin" => ["authp/user", "authp/advanced", "authp/admin", "dev/user", "dev/advanced", "dev/admin"].sort.join(" "),
  }

  def get_user(user, roles)
    [
      "transform user {",
      "\tmatch email #{user[0]}",
      "\taction add role #{roles[user[1]]}",
      "\tui link \"Plex\" \"https://plex.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/\" icon \"las la-film\"",
      "\tui link \"Overseerr\" \"https://overseerr.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/\" icon \"las la-search\"",
      # "\tui link \"My Identity\" \"/whoami\" icon \"las la-user\"",
      "}",
    ]
  end

  template_regex = /### USERS BLOCK START ###(.*?)### USERS BLOCK END ###/m

  caddyfile.gsub!(template_regex) do |match|
    [
      "### USERS BLOCK START ###",
      get_users.map { |email| get_user(email, roles_map) }.flatten,
      "### USERS BLOCK END ###",
    ].flatten.join("\n\t\t\t")
  end

  File.write(caddy_file_path, caddyfile)
end
