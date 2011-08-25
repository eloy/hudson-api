require 'rubygems'
require 'json'
require 'net/http'
module Hudson

  # set default settings
  @@settings = {:url => 'http://localhost:8080/hudson', :user => nil, :password => nil, :api_suffix=>"/api/json" }

  def self.[](param)
    return @@settings[param]
  end

  def self.[]=(param,value)
    param = param.to_sym if param.kind_of?(String)
    if param == :host or param == :url
      value = "http://#{value}" if value !~ /https?:\/\//
      @@settings[:url] = value
    else
      @@settings[param]=value
    end
  end


  # Base class for all Hudson objects
  class HudsonBase
    def self.send_post_request(url, data={})
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request.add_field "Content-Type", "application/xml"
      request.set_form_data(data)
      response = http.request(request)
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    def self.send_xml_post_request(url, xml)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(Hudson[:user], Hudson[:password]) if Hudson[:user] and Hudson[:password]
      request.add_field "Content-Type", "application/xml"
      request.body = xml
      response = http.request(request)
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end
  end

end

Dir[File.dirname(__FILE__) + '/api/*.rb'].each {|file| require file }


