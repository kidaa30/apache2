#
# Cookbook Name:: apache2
# Recipe:: mod_ssl
#
# Copyright 2008-2013, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
unless node['apache']['listen'].values.any? { |ports| ports.include?(node['apache']['mod_ssl']['port']) }
  node['apache']['listen'].each_key do |address|
    node.default['apache']['listen'][address] = node['apache']['listen'][address] + [node['apache']['mod_ssl']['port']]
  end
end

include_recipe 'apache2::default'

if platform_family?('rhel', 'fedora', 'suse')
  package node['apache']['mod_ssl']['pkg_name'] do
    notifies :run, 'execute[generate-module-list]', :immediately
  end

  file "#{node['apache']['dir']}/conf.d/ssl.conf" do
    action :delete
    backup false
  end
end

template 'ssl_ports.conf' do
  path "#{node['apache']['dir']}/ports.conf"
  source 'ports.conf.erb'
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
end

apache_module 'ssl' do
  conf true
end

if node['apache']['version'] == '2.4'
  include_recipe 'apache2::mod_socache_shmcb'
end
