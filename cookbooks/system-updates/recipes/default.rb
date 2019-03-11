execute 'update-upgrade' do
    command <<-EOF
      yum upgrade -y  
    EOF
    # ignore_failure true
  end