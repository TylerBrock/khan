require 'uri'
require 'net/http'
require 'ruby-progressbar'

module Khan
  module Downloader
    DOWNLOAD_HOST = 'downloads.mongodb.org'
    EXTENSION = '.tgz'

    def self.bits_and_os
      bits, kernel = RUBY_PLATFORM.split('-')

      if kernel =~ /darwin/
        os = 'osx'
      elsif os =~ /linux/
        os = 'linux'
      else
        raise "Plaform not support for downloder"
      end
      [bits, os]
    end

    def self.file_name(bits, os, version='latest')
      ["mongodb", os, bits, version].join('-') + EXTENSION
    end

    def self.build_uri(version)
      bits, os = bits_and_os
      uri = URI::HTTP.build({
        :host => DOWNLOAD_HOST,
        :path => ['/' + os, file_name(bits, os, version)].join('/')
      })
    end

    def self.download(version)
      uri = build_uri(version)
      name = "mongo-#{version}#{EXTENSION}"

      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri.request_uri

        http.request request do |response|
          size = response['content-length'].to_f
          received = 0
          progress_bar = ProgressBar.create(:title => name, :format => "%t [%B] %P%%")

          open name, 'w' do |io|
            response.read_body do |chunk|
              received += chunk.size
              progress_bar.progress = (received / size) * 100
              io.write chunk
            end
          end
        end
      end
    end

    def self.extract(version)
      #numfiles = `tar vft "mongo-#{version}#{EXTENSION}" | wc -l`
      #puts numfiles
      `tar -zxf "mongo-#{version}#{EXTENSION}"`
    end
  end
end