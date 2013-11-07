# yamon-grid
# synthetize many yamon sources to one page

require 'rubygems'
require 'sinatra'
require 'haml'

require 'uri'
require 'timeout'
require 'json'
require 'net/http'

require 'config'

SSL_KEY="ssl_client.key"
SSL_CRT="ssl_client.crt"

# Deal with a URI target.
def uri_target(options)
    uri = URI.parse(options[:uri])
    http = Net::HTTP.new(uri.host, uri.port)

    if uri.scheme == 'https' then
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    if options[:use_cert] then
      http.key = OpenSSL::PKey::RSA.new(File.read(SSL_KEY))
      http.cert = OpenSSL::X509::Certificate.new(File.read(SSL_CRT))
    end

    # Timeout handler, just in case.
    response = nil
    begin
        Timeout::timeout(options[:timeout]) do
            request = Net::HTTP::Get.new(uri.request_uri)
            if (options[:user] and options[:pass]) then
                request.basic_auth(options[:user], options[:pass])
            end
            response = http.request(request)
        end
    #rescue Timeout::Error
    #    return []
    #rescue Exception => e
    #    return []
    end

    # We must get a proper response.
    if not response.code.to_i == 200 then
		return []
    end

    # Make a JSON object from the response.
    return JSON.parse response.body
end


def duration_human(t)
  diff = (Time.now - t)
  days,hours,minutes = 0
  ret = ""

  if diff >= (60*60*24)
    days = diff / (60*60*24)
    diff = diff % (60*60*24)
    ret = days.to_i.to_s + 'd'
  end

  if diff >= (60*60)
    hours = diff / (60*60)
    diff  = diff % (60*60)
    ret = ret + ' ' if ret != ''
    ret = ret + hours.to_i.to_s + 'h'
  end

  if diff >= 60
    minutes = diff / 60
    ret = ret + ' ' if ret != ''
    ret = ret + minutes.to_i.to_s + 'm'
  end

  ret# + '/'+ diff.to_s
end

def set_menu (page)
  @menu = {'astreinte'=>nil, 'complet'=>nil}
  @menu[page] = 'active'
end

def set_additional_fields (hash)
  hash.each do |i|
    t = Time.at(i['check_date'].to_i)
    i['check_date2']=t.strftime("%d/%m %H:%M")
    i['duration']=duration_human(t)
  end

  hash
end

def get_json (url, is_yamon, use_cert=false)

  if is_yamon
    json = []

    j = uri_target ({:uri => url, :timeout => 5, :use_cert=>use_cert})

    j.each do |i|
      json << i["current_alerts"]
    end
  else

    json = uri_target ({:uri => url, :timeout => 3})
  end
  

  json = set_additional_fields json
  
  json
end

['/', '/ast'].each do |path|
  get path do
    @alerts = {}

    CONFIG.each do |name, config|
        @alerts[name] = get_json(config['astr_url'], config['yamon'], config['use_cert'])
    end

    set_menu 'astreinte'
    haml :index
  end
end

get '/all' do
  @alerts = {}

  CONFIG.each do |name, config|
      @alerts[name] = get_json(config['full_url'], config['yamon'], config['use_cert'])
  end

  set_menu 'complet'
  haml :index
end
