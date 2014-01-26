require 'sequel'
require 'yaml'

module App
  class Registry

    @@db = nil
    @@config = nil

    def self.db
      if not @@db
        @@db = Sequel.connect(self.config["db"])
      end
      return @@db
    end

    def self.config
      if not @@config
        filename = ENV['TP_CONFIG'] || 'etc/config.yml'
        @@config = YAML.load_file(filename)
      end
      @@config
    end

  end
end
