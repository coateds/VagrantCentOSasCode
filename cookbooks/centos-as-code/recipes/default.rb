execute "append to log" do
  command <<-EOF
    echo 'start new' > #{node['log-file']['path']}
    date >> #{node['log-file']['path']}
    echo ''  >> #{node['log-file']['path']}
    # echo '*********'  >> #{node['log-file']['path']}
  EOF
end