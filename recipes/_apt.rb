execute "apt-get update -y"

node.override['apt']['unattended_upgrades']['enable']                    = true
node.override['apt']['unattended_upgrades']['allowed_origins']           = ['${distro_id}:${distro_codename}-security']
node.override['apt']['unattended_upgrades']['auto_fix_interrupted_dpkg'] = true

package_blacklist = node.override['apt']['unattended_upgrades']['package_blacklist'].to_a
package_blacklist.push('postgresql*')

node.override['apt']['unattended_upgrades']['package_blacklist'] = package_blacklist

include_recipe 'apt::unattended-upgrades'
