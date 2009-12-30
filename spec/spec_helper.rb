$LOAD_PATH.unshift(File.expand_path('../', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'rails3_datamapper'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
end
