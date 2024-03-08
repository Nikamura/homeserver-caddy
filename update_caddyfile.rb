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
    "basic" => ["authp/user"].join(" "),
    "advanced" => ["authp/user", "authp/advanced"].sort.join(" "),
    "admin" => ["authp/user", "authp/advanced", "authp/admin"].sort.join(" "),
  }

  def link(name, url, icon)
    "\tui link \"#{name}\" \"#{url}\" icon \"#{icon}\""
  end

  def get_user(user, roles)
    links = [
      link("Plex", "https://plex.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-film"),
      link("Overseerr", "https://overseerr.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-search"),
    ]
    role = user[1]

    if role == "advanced" || role == "admin"
      links << link("Deluge", "https://deluge.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-download")
      links << link("Radarr", "https://radarr.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-film")
      links << link("Sonarr", "https://sonarr.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-tv")
      links << link("Sonarr Anime", "https://sonarr-anime.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-user-astronaut")
      links << link("Bazarr", "https://bazarr.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-closed-captioning")
      links << link("Bazarr Anime", "https://bazarr-anime.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-closed-captioning")
      links << link("Chat GPT", "https://lobe.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-comments")
    end
    
    if role == "admin"
      links << link("VSCode", "https://code.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-code")
      links << link("HASS", "https://hass.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-home")
      links << link("DSM", "https://dsm.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-server")
      links << link("Uptime", "https://uptime.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-clock")
      links << link("Tautulli", "https://tautulli.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-chart-line")
      links << link("Prowlarr", "https://prowlarr.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-search-plus")
      links << link("Radarr 4k", "https://radarr-4k.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-film")
      links << link("Sonarr 4k", "https://sonarr-4k.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-tv")
      links << link("Bazarr 4k", "https://bazarr-4k.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-closed-captioning")
      links << link("Minio", "https://minio.#{ENV.fetch("CADDY_DOMAINNAME_DEV")}/", "las la-cloud")
    end
    [
      "transform user {",
      "\tmatch email #{user[0]}",
      "\taction add role #{roles[role]}",
      *links,
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
