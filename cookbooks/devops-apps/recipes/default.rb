package "git"

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