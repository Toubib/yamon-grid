# config.ru
$: << File.expand_path(File.dirname(__FILE__))

require 'main'
run Sinatra::Application
