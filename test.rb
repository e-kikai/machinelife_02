
require 'sshkit'
require 'sshkit/dsl'
include SSHKit::DSL

SSHKit.config.output_verbosity = Logger::DEBUG

remote_host = SSHKit::Host.new("aws_machinelife_staging_02")
remote_host.user = "ec2-user"
# remote_host.user = "catalog"
# remote_host.ssh_options =
#   {
#     # verify_host_key: :always,
#     keys: %w[~/.ssh/machinelife_02.pem],
#     forward_agent: true,
#     auth_methods: %w[publickey],
#     port: 22
#   }

on remote_host do
  execute :ls
end
