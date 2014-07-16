class Requester

    require 'open-uri'
    require 'net/http'

    def self.get_json(url)
        return JSON.parse(get_content(url),:symbolize_names => true)
    end

    def self.get_content(url)
        return open(url).read
    end
end