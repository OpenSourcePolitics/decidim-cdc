# frozen_string_literal: true

task :restore_dump do
  $stdout.puts "Path to dump file (/path/to/dump): "
  local_path = $stdin.gets.to_s.strip
  dump = local_path.split("/")[-1]
  sh "docker cp '#{local_path}' decidim-cdc-database-1:'/tmp/#{dump}'"
  sh "docker exec -it decidim-cdc-database-1 su postgres -c 'pg_restore -c -O -v -x --no-owner -d osp_app /tmp/#{dump}'"
end
