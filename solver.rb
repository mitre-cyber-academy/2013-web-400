#!/usr/bin/env ruby

require 'base64'
require 'openssl'

class ConvertCookie

	# Encode session cookies as Base64
	class Base64
	    def encode(str)
	      [str].pack('m').gsub(/\n/, '')
	    end

	    def decode(str)
	      str.unpack('m').first
	    end

		# Encode session cookies as Marshaled Base64 data
		class Marshal < Base64
			def encode(str)
		  		super(::Marshal.dump(str))
			end
			def decode(str)
		    	::Marshal.load(super(str)) rescue nil
		  	end
		end
	end

	attr_accessor :decoded_cookie, :encoded_cookie
	def initialize(secret = nil)
		@secret = secret
		@secret ||= 'c95f554820d160cac5792840a37900b98b30cd61f7dc7260a7532a8ffe15f46ddfd1e9005d648119a4f77d7f4221cb19ee6ef7d0bd4e08a42436502c212e9848'
		@encoded_cookie = nil
		@decoded_cookie = nil
		@coder = Base64::Marshal.new
	end
	def decrypt(encoded)
		@encoded_cookie = encoded
		decoded = @coder.decode(encoded)
		puts decoded
	end
	def encrypt(decoded, secret = nil)
		@secret ||= secret
	    data = @coder.encode(decoded)
	    data = "#{data}--#{generate_hmac(data, @secret)}"
	    puts data
	end

	private 
	def generate_hmac(data, secret)
    	OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, secret, data)
    end
end

choice = nil
while not %w(e d).include? choice do
	print 'Would you like to encode or decode? (e or d): '
	choice = gets.chomp
end

converter = ConvertCookie.new
print 'please provide a string: '
case choice
when 'd'
	converter.decrypt(gets.chomp)
when 'e'
	key = eval(gets.chomp)
	print 'Please provide a secret: '
	converter.encrypt(key, gets.chomp)
end