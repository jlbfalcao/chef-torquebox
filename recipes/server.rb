

version = node[:torquebox][:version]
prefix = "/opt/torquebox-#{version}"
current = "/opt/torquebox-current"

package "unzip"
package "upstart"

user "torquebox" do
  comment "torquebox"
  system true
  shell "/bin/false"
end

puts node[:torquebox][:url]

install_from_release('torquebox') do
  release_url  node[:torquebox][:url]
  home_dir     prefix
  action       [:install, :install_binaries]
  version     version
  checksum node[:torquebox][:checksum]
  not_if{ File.exists?(prefix) }
end

template "/etc/profile.d/torquebox.sh" do
  mode "755"
  source "torquebox.erb"
end

link current do
  to prefix
end

# install upstart
execute "torquebox-upstart" do
  command "rake torquebox:upstart:install"
  creates "/etc/init/torquebox.conf"
  cwd current
  action :run
  environment ({
    'TORQUEBOX_HOME'=> current,
    'JBOSS_HOME'=> "#{current}/jboss",
    'JRUBY_HOME'=> "#{current}jruby",
    'PATH' => "#{ENV['PATH']}:#{current}/jruby/bin"
  })
end


