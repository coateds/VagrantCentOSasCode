
# package "yum-utils"
# execute "yum -y groupinstall development"

yumgroup 'development' do
  action :install
end

package "epel-release"

remote_file '/home/vagrant/ius-release.rpm' do
  source 'https://centos7.iuscommunity.org/ius-release.rpm'
  mode '0755'
  # checksum '3a7dac00b1' # A SHA256 (or portion thereof) of the file.
  checksum '0a264399ff09b2331efcc3ebb8e2cfb6a886c2c257be0d9af9b56e58f84deb8c'
end

rpm_package "/home/vagrant/ius-release.rpm"

# execute "yum -y install https://centos7.iuscommunity.org/ius-release.rpm"
# execute 'install-python-dependency' do
#   command <<-EOF
#   yum -y install https://centos7.iuscommunity.org/ius-release.rpm
#   EOF
#   ignore_failure true
# end

# Use this form to be sure remote repositories are read to find packages
# package "python36u" do
#     flush_cache [ :before ]
# end

package %w(python36u-pip python36u-devel)

link '/bin/python3' do
  to '/bin/python3.6'
end