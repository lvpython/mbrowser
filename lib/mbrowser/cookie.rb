require 'yaml'
module Mbrowser
  class Cookie
    @@session_cookies = Hash.new { |k, v| k[v] = {} }
    COOKIE_FILE = '/tmp/mbrowser_cookie.yml'

    class << self
      def load_cookie_from_disk
        @@session_cookies = YAML.load_file(COOKIE_FILE)
      rescue
        {}
      end

      def dump_cookie_to_file
        File.open(COOKIE_FILE, 'w') { |f| f.write @@session_cookies.to_yaml }
      end

      def export_cookies(domain)
        load_cookie_from_disk if @@session_cookies.empty?
        cookie_store = @@session_cookies.select { |suffix_domain, _value| domain.include? suffix_domain }.each_with_object({}) { |n, m| m.merge!(n[1]) }
        cookies_str = cookie_store.clone.keys.map do |key|
          "#{cookie_store[key].empty? ? '' : "#{key}=#{cookie_store[key]};"}"
        end.join(' ')
        cookies_str
      end

      def import_cookies(curl)
        cookie_headers = curl.header_str.split("\r\n").map { |v| v if v =~ /^Set-Cookie:.*/ }.compact

        cookie_headers.map do |v|
          v = v[11..-1]
          cookie_hash = v.split(';').each_with_object({}) { |item, m| m.merge!(item.split('=')[0].strip.to_sym => item.split('=')[1..-1].join('=').to_s) }
          domain = cookie_hash[:domain] || curl.domain
          cookie_hash.delete_if { |k, _v| [:domain, :expires, :path, :HttpOnly].include? k }
          cookie_hash.each do |key, value|
            if value.to_s.downcase.strip != 'deleted'
              @@session_cookies[domain][key] = value.to_s
            else
              @@session_cookies[domain].delete key
            end
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
