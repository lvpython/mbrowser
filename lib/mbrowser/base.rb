require 'mbrowser/cookie'
require 'uri'
require 'curl'
class Curl::Easy
	attr_accessor :domain
end
module Mbrowser
  class Base
  	
  	USER_AGENT = { "firefox" => "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:16.0) Gecko/20100101 Firefox/16.0"
  	}
  	ACCEPT = {"html+xml" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  						"json" => "application/json, text/javascript, */*; q=0.01"}
    ACCEPT_ENCODING = {"default" => "", "gzip" => "gzip,deflate,sdch"}

  	def initialize(attrs = {})
  		domain =  attrs[:host]
  		my_host = URI.parse attrs[:url]
  		domain ||= my_host.host
			@is_gzip = true
  		@curl = Curl::Easy.new(attrs[:url])
  		@curl.domain = domain
		  @curl.follow_location = attrs[:follow_location] || true
		  @curl.enable_cookies = true
		  @curl.post_body = attrs[:post_body] if attrs[:post_body]
		  @curl.cookies = Mbrowser::Cookie.export_cookies domain
		  @curl.dns_cache_timeout= attrs[:dns_timeout] || 60
		  @curl.max_redirects = attrs[:redirect_num] || 10
		  @curl.use_ssl = attrs[:use_ssl] || Curl::CURL_USESSL_TRY
		  @curl.ssl_verify_host = attrs[:verify_host] || false
		  @curl.ssl_verify_peer = attrs[:verify_peer] || false
		  @curl.useragent = attrs[:user_agent] || USER_AGENT["firefox"]

		  custom_headers = {"Accept-Encoding" => ACCEPT_ENCODING["gzip"]}
		  custom_headers.merge!({"Referer" => attrs[:header_referer]}) if attrs[:header_referer]
		  if attrs[:header_accept]
		  	if attrs[:header_accept] == "json"
		  		custom_headers.merge!({"X-Requested-With" => "XMLHttpRequest"})
		  	end
		  	custom_headers.merge!({"Accept" => ACCEPT[attrs[:header_accept]]})
		  end

		  if attrs[:accept_encoding]
		  	custom_headers.merge!({"Accept-Encoding" => ACCEPT_ENCODING[attrs[:accept_encoding]]}) 
		  	if attrs[:accept_encoding] != "gzip"
		  		@is_gzip = false
		  	end
		  end
		  custom_headers.merge!({"X-CSRF-Token" => attrs[:header_csrf]}) if attrs[:header_csrf]
		  custom_headers.merge!({"Host" => domain })
		   custom_headers.merge!({"X-CSRF-Token" => attrs[:host]}) if attrs[:host]
		  custom_headers.merge! attrs[:other_headers] if attrs[:other_headers] 
		  @curl.headers = custom_headers.map{|key,value| "#{key}: #{value}"}

  	end
  end
end