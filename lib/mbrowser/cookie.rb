require 'yaml'
module Mbrowser
  class Cookie
		$session_cookies = {}
  	COOKIE_FILE = '/tmp/mbrowser_cookie.yml'
  	class << self
  		def load_cookie_from_disk
  			$session_cookies = YAML::load_file(COOKIE_FILE) rescue {}
  		end

  		def dump_cookie_to_file
  			File.open(COOKIE_FILE, 'w') {|f| f.write $session_cookies.to_yaml }
  		end

			def export_cookies domain
				load_cookie_from_disk if $session_cookies.empty?
				cookie_store = $session_cookies.select{ |suffix_domain,value| domain.include? suffix_domain}.inject({}){|m,n| m.merge!(n[1]);m}
				cookies_str = cookie_store.clone.keys.map{ |key|
				 "#{cookie_store[key].empty? ? "" : "#{key}=#{cookie_store[key]};"}"
				  }.join(" ")
				cookies_str  
			end

			def import_cookies curl

				headers= curl.header_str.split("\r\n").map{|v| v.split(":")}.select{|item| item[0].downcase=="set-cookie"}
				cookie_hashs = headers.map{|v| v[1].split("; ")}.reduce(:+).map{|v| v.split("=")}.inject({}){|m,item| m.merge!({item[0].strip.to_sym=>item[1].to_s});m}
				return unless cookie_hashs.is_a? Hash
				domain = cookie_hashs[:domain]
				cookie_hashs.delete(:domain)
			  cookie_hashs.delete(:expires)
			  cookie_hashs.delete(:path)
			  cookie_hashs.delete(:HttpOnly)
			  $session_cookies[domain] ||= {}
			  cookie_hashs.each do |key,value|
			    $session_cookies[domain][key] = value.to_s
			  end
			  dump_cookie_to_file
			end
		end
  end
end

class NilClass
  def map
  end
  def each
  end
end