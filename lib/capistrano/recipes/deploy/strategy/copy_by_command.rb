require 'open3'
require 'parallel'
require 'capistrano'
require 'capistrano/recipes/deploy/strategy/copy'

module Capistrano
  module Deploy
    module Strategy
      # Copy storategyを拡張
      # 転送処理をNet::SSHでなくscpコマンドを直接実行する形に変更
      # deploy_scp_processes オプションでSCP実行の並列プロセス数を指定可能
      # set :deploy_scp_processes, 10
      class CopyByCommand < Copy
        def distribute!
          task, servers = filter_servers({})
          process_num = configuration[:deploy_scp_processes] || 5
          results = Parallel.map(servers, in_processes: process_num) do |server|
            command = "scp #{filename} #{server}:#{remote_filename}"
            execute(command) do
              Open3.capture3(command)
            end
          end
          decompress_remote_file
        end
      end
    end
  end
end
