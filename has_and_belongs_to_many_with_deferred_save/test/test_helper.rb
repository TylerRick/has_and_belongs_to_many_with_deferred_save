require 'rubygems'
require 'facets/core/kernel/require_local'

# This loads the application's (default) test_helper, which loads the environment, etc.
require_local 'rails_root/test/test_helper'

# This puts our working directory into the root of our test app.
Dir.chdir File.dirname(__FILE__) + 'rails_root/'

# Side effect you should be aware of:
# rake_test_loader will have trouble finding your tests due to this chdir... 

