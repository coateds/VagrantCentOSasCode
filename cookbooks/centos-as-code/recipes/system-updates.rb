execute 'log header' do
  command <<-EOF
    echo '*********'  >> #{node['log-file']['path']}
    echo 'system updates recipe' >> #{node['log-file']['path']}
    echo ''  >> #{node['log-file']['path']}
  EOF
end

execute 'update-upgrade' do
  command <<-EOF
    yum upgrade -y  
  EOF
  # ignore_failure true
end