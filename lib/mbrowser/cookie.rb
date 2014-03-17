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
				cookie_headers= curl.header_str.split("\r\n").map{|v|  v if v =~ /^Set-Cookie:.*/ }.compact
				
				cookie_hashs = cookie_headers.map do |v| 
					v = v[11..-1]
					cookie_hash = v.split(";").inject({}){|m,item| m.merge!({item.split("=")[0].strip.to_sym=>item.split("=")[1..-1].join("=").to_s});m}
					domain = cookie_hash[:domain]
					domain ||= curl.domain
					cookie_hash.delete(:domain)
				  cookie_hash.delete(:expires)
				  cookie_hash.delete(:path)
				  cookie_hash.delete(:HttpOnly)
				  $session_cookies[domain] ||= {}
				  cookie_hash.each do |key,value|
				    $session_cookies[domain][key] = value.to_s
				  end
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