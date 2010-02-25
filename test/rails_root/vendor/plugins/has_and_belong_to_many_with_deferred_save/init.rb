# This tricks the test app into loading the plugin from its parent directory.
# The alternatives migth be:
# * creating a symlink from plugin_name/rails_root/vendor/plugins/plugin_name to plugin_name
# * creating an svn:external at plugin_name/rails_root/vendor/plugins/plugin_name that pulls in the contents of plugin_name (not only would that create a circular dependency, it also would mean that changes you made to plugin_name wouldn't show up in rails_root until you committed and updated)

#require "#{RAILS_ROOT}/../init.rb"
init_path = "#{RAILS_ROOT}/../../init.rb"
silence_warnings { eval(IO.read(init_path), binding, init_path) }
