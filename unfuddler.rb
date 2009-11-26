#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'erb'
require 'net/https'

include ERB::Util

UNFUDDLE_SETTINGS = {
  :subdomain  => 'mysubdomain',
  :username   => 'username',
  :password   => 'password',
  :ssl        => true,
  :project_id => 1234
}

get '/' do
  erb :index
end

post '/' do
  http = Net::HTTP.new("#{UNFUDDLE_SETTINGS[:subdomain]}.unfuddle.com", UNFUDDLE_SETTINGS[:ssl] ? 443 : 80)

  # if using ssl, then set it up
  if UNFUDDLE_SETTINGS[:ssl]
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  request = Net::HTTP::Post.new("/api/v1/projects/#{UNFUDDLE_SETTINGS[:project_id]}/tickets", {'Content-type' => 'application/xml'})
  request.basic_auth UNFUDDLE_SETTINGS[:username], UNFUDDLE_SETTINGS[:password]
  request.body = "<ticket><priority>#{params[:priority]}</priority><summary>#{html_escape(params[:summary])}</summary><description>From: #{html_escape("#{params[:name]} (#{params[:email]})")}\n\n#{html_escape(params[:description])}</description></ticket>"
  http.request(request)
  
  erb :thanks
end
