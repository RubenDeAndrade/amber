require "./field.cr"

module Amber::CLI
  class Scaffold < Teeplate::FileTree
    directory "#{__DIR__}/scaffold"

    @pjtype : String
    @name : String
    @fields : Array(Field)
    @visible_fields : Array(String)
    @database : String
    @language : String
    @timestamp : String
    @primary_key : String

    def initialize(@name, fields)
      puts "INITIALIZE SCAFFOLD"
      @database = database
      @language = language
      @pjtype = pjtype
      puts @pjtype
      @fields = fields.map { |field| Field.new(field, database: @database) }
      @fields += %w(created_at:time updated_at:time).map do |f|
        Field.new(f, hidden: true, database: @database)
      end
      @timestamp = Time.now.to_s("%Y%m%d%H%M%S")
      @primary_key = primary_key
      @visible_fields = visible_fields
      add_route
    end

    def pjtype
      if File.exists?(AMBER_YML) &&
         (yaml = YAML.parse(File.read AMBER_YML)) &&
         (pjtype = yaml["type"]?)
        pjtype.to_s
      else
        return "app"
      end
    end

    def database
      if File.exists?(DATABASE_YML) &&
         (yaml = YAML.parse(File.read DATABASE_YML)) &&
         (database = yaml.first)
        database.to_s
      else
        return "pg"
      end
    end

    def language
      if File.exists?(AMBER_YML) &&
         (yaml = YAML.parse(File.read AMBER_YML)) &&
         (language = yaml["language"]?)
        language.to_s
      else
        return "slang"
      end
    end

    def primary_key
      case @database
      when "pg"
        "id BIGSERIAL PRIMARY KEY"
      when "mysql"
        "id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY"
      when "sqlite"
        "id INTEGER NOT NULL PRIMARY KEY"
      else
        "id INTEGER NOT NULL PRIMARY KEY"
      end
    end

    def filter(entries)
      puts "=" * 60
      puts "SCAFFOLS FILTER"
      puts @pjtype
      puts "=" * 60
      entries.reject { |entry| (entry.path.includes?("src/views") && !entry.path.includes?(".#{@language}")) || (entry.path.includes?("src/views") && @pjtype == "api") }
    end

    def visible_fields
      @fields.reject { |f| f.hidden }.map do |f|
        f.reference? ? "#{f.name}_id" : f.name
      end
    end

    def add_route
      routes = File.read("./config/routes.cr")
      replacement = <<-ROUTE
      routes :web do
          resources "/#{@name}s", #{@name.capitalize}Controller
      ROUTE
      File.write("./config/routes.cr", routes.gsub("routes :web do", replacement))
    end
  end
end
