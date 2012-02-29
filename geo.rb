#!/usr/bin/env ruby

require 'rubygems'
require 'tempfile'
require 'exifr'
require 'yaml'
require 'geokit'
require 'net/http'
require 'open-uri'


def getFileGps(fileName)
    if fileName == nil
        return nil
    end
    @fileGps = EXIFR::JPEG.new(fileName).gps
    if (@fileGps == nil)
        puts 'no gps info found'
        return nil
    end
    return [@fileGps.latitude, @fileGps.longitude]
end

def downloadImage(url)
    @localImage = '/tmp/image.jpg'
    File.open(@localImage, "wb") do |saved_file|
        begin
            open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |remoteFile|
                if (remoteFile.content_type != 'image/jpeg')
                    puts 'invalid content type:' + remoteFile.content_type
                    return nil
                end
                saved_file.write(remoteFile.read)
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
        puts 'Invalid file : ' + imageFile
        exit
    end

    @gps = getFileGps(imageFile)
    
    if @gps != nil
        puts GoogleGeocoder.reverse_geocode(@gps).full_address
    end
end

