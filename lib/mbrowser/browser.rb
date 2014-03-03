require 'mbrowser/base'
require 'mbrowser/cookie'
require 'zlib'
require 'nokogiri' 
require 'json'

module Mbrowser
  class Browser < Mbrowser::Base
    RESERVED_CHARS=['[',']','+','=','/','#','&',':']
  	METHOD_GROUPS = ["get", "post", "put", "delete"]
    HTML = "html"
    JSON = "json"

  	def initialize(attrs = {})
  		super(attrs)
  		@method = attrs[:method]
  		@payload = attrs[:payload] || {}
      @pretty_response = ""
  		raise "unsupport method #{@method}" unless METHOD_GROUPS.include? @method
  		
  	end

  	def open
  		unless @payload.empty?
        post_data = @payload.map{|key,value| "#{encode_data(key)}=#{encode_data(value)}"}.join("&")
  			@curl.send("http_#{@method}", post_data)
  		else
  			@curl.send("http_#{@method}")
  		end
  		Mbrowser::Cookie.import_cookies @curl
  	end

  	def response_code
  		@curl.response_code
  	end

  	def header_str
  		@curl.header_str || ""
  	end

  	def body_str
      if @is_gzip
  		  gz = Zlib::GzipReader.new(StringIO.new(@curl.body_str))    
        responses = gz.read
      else
        @curl.body_str
      end
  	end

    def formatted_response format = HTML
      if format == JSON
        @pretty_response = JSON.parse(body_str)
      elsif format == HTML
        @pretty_response = Nokogiri::HTML(body_str)
      end
    end

    def pretty_response format = HTML
      if @pretty_response.is_a? String
        formatted_response format
      end
      @pretty_response
    end

    private      

    def encode_data(value)
        value.to_s.strip.split('').map{ |char|
           if RESERVED_CHARS.include? char
             "%#{char.unpack('H*')[0].upcase}"
           else
             char
           end
        }.reduce(:+)
    end

    def header_token_value(token)
      header_str.split("\r\n").map{|v| v.split(": ")}.select{|item| item[0].downcase==token.downcase}
    end
  end
end