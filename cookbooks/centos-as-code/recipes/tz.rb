execute 'log header' do
  command <<-EOF
    echo '*********'  >> #{node['log-file']['path']}
    echo 'timezone recipe' >> #{node['log-file']['path']}
    echo ''  >> #{node['log-file']['path']}
  EOF
end

link '/etc/localtime' do
  to '/usr/share/zoneinfo/America/Los_Angeles'
end

execute 'log timezone' do
  command <<-EOF
    echo 'timezone not set' >> #{node['log-file']['path']}
  EOF
  not_if 'ls -ll /etc/localtime | grep Los_Angeles'
end