execute 'log header' do
  command <<-EOF
    echo '*********'  >> #{node['log-file']['path']}
    echo 'devops applications recipe' >> #{node['log-file']['path']}
    echo ''  >> #{node['log-file']['path']}
  EOF
end

remote_file '/etc/pki/rpm-gpg/microsoft.asc' do
  source 'https://packages.microsoft.com/keys/microsoft.asc'
  action :create
end

file "/etc/yum.repos.d/vscode.repo" do
  content "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/microsoft.asc
"
end

package "code" do
  flush_cache [ :before ]
end

execute 'vscode installed' do
  command <<-EOF
    echo 'vscode not installed' >> #{node['log-file']['path']}
  EOF
  # \b is a word boundary switch
  not_if 'yum list installed | grep "\bcode.x86_64"'
end

# Add/Configure the wandisco repo to get the latest version of Git
remote_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco' do
  source 'http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco'
  action :create
end

file "/etc/yum.repos.d/wandisco-git.repo" do
  content "[WANdisco-git]
name=WANdisco Distribution of git
baseurl=http://opensource.wandisco.com/rhel/$releasever/git/$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco"
end

package "git"

execute 'git installed' do
  command <<-EOF
    echo 'git not installed' >> #{node['log-file']['path']}
  EOF
  # \b is a word boundary switch
  not_if 'yum list installed | grep "\bgit.x86_64"'
end