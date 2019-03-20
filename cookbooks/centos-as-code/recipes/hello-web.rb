execute 'log header' do
  command <<-EOF
    echo '*********'  >> #{node['log-file']['path']}
    echo 'hello-web recipe' >> #{node['log-file']['path']}
    echo ''  >> #{node['log-file']['path']}
  EOF
end

package 'curl'

package node['hello_web']['package']

cookbook_file "#{node['hello_web']['docroot']}/index.html" do
  source 'index.html'
  action :create
end

service node['hello_web']['service'] do
  supports status: true, restart: true, reload: true
  action %i(enable start)
end

execute 'log web' do
  command <<-EOF
    echo 'web not running' >> #{node['log-file']['path']}
  EOF
  not_if 'curl localhost | grep Gooberlicious!'
end