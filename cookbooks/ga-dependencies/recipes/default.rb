# gonna need two levels of idempotence
# first, only add lines to the .bashrc file once
#   echo a unique comment to the top of the code block
#   set a guard to not append the lines if the comment exists
# second, the bash script itself has a conditional to prevent the
#   Guest Additions from installing if installed already
execute "add line(s) to installga script" do
    command <<-EOF
      echo '# InstallGuestAdditions' >> /home/vagrant/.bashrc
      echo 'if [ "$(ls /opt | grep 6.0.4)" == "" ]' >> /home/vagrant/.bashrc
      echo 'then' >> /home/vagrant/.bashrc
      echo '  sudo /run/media/vagrant/VBox_GAs_6.0.4/VBoxLinuxAdditions.run 2> /dev/null' >> /home/vagrant/.bashrc
      echo 'fi' >> /home/vagrant/.bashrc
    EOF
    not_if 'cat /home/vagrant/.bashrc | grep InstallGuestAdditions'
  end

package "epel-release"

# This line is effectively idempotent
execute "sudo yum update kernel* -y"

package %w(make gcc perl dkms bzip2 kernel-headers kernel-devel) 