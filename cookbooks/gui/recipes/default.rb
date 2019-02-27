package "kernel-devel"

# multiple commands to install Gnome
execute "install gnome" do
  command <<-EOF
    yum groupinstall -y 'gnome desktop'
    yum install -y 'xorg*'
    yum remove -y initial-setup initial-setup-gui
    systemctl set-default graphical.target
    systemctl isolate graphical.target
  EOF
  not_if 'systemctl get-default | grep graphical'
end
