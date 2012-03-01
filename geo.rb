#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'yaml'
require 'net/http'
require 'open-uri'


def getFileGps(fileName)
    if fileName == nil
        return nil
    end
    begin
    @exifInfo = EXIFR::JPEG.new(fileName)
    rescue
        puts 'broken image file'
        return nil
    end
    @fileGps = @exifInfo.gps
    if (@fileGps == nil)
        puts 'no gps info found'
        if (@exifInfo.make && @exifInfo.model)
            puts YAML::dump @exifInfo.make + ' : ' + @exifInfo.model 
        end
        return nil
    end
    return [@fileGps.latitude, @fileGps.longitude]
end

def downloadImage(url)
    @localImage = '/tmp/image.jpg'
    File.open(@localImage, "wb") do |localFile|
        begin
            open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |remoteFile|
                if (remoteFile.content_type != 'image/jpeg')
                    puts 'invalid content type:' + remoteFile.content_type
                    return nil
                end
                localFile.write(remoteFile.read)
                return @localImage
            end
        rescue
            return nil
        end
    end
    return nil
end

include Geokit::Geocoders

if (0 === ARGV.count) 
    puts "try some files as parameters"
end 

ARGV.each do |imageFile|
    if (imageFile.match('http'))
        imageFile = downloadImage(imageFile)
    end

    if (imageFile === nil || !File::exists?(imageFile))
        puts 'Invalid file : ' + imageFile.to_s
        exit
    end

    @gps = getFileGps(imageFile)
    
    if @gps != nil
        puts GoogleGeocoder.reverse_geocode(@gps).full_address
    end
end

