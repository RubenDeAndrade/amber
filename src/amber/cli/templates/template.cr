require "teeplate"
require "secure_random"
require "./app"
require "./scaffold"
require "./model"
require "./controller"
require "./migration"
require "./mailer"
require "./socket"
require "./channel"
require "./auth"

module Amber::CLI
  class Template
    getter name : String
    getter directory : String
    getter fields : Array(String)

    def initialize(name : String, directory : String, fields = [] of String)
      if name.match(/\A[a-zA-Z]/)
        @name = name
      else
        raise "Name is not valid."
      end

      @directory = File.join(directory)
      unless Dir.exists?(@directory)
        Dir.mkdir_p(@directory)
      end

      @api = false
      @fields = fields
    end

    def generate(template : String, options = nil)
      case template
      when "app"
        if options
          puts options.to_s
          puts "Rendering App #{name} in #{directory}"
          puts "yoooo"
          puts "=" * 60
          puts options.d
          puts "=" * 60
          puts options.t
          puts "=" * 60
          @api = options.api?
          puts "api:#{@api}"
          puts "=" * 60
          App.new(name, options.d, options.t, options.api?).render(directory, list: true, color: true)
          if options.deps?
            puts "Installing Dependencies"
            puts `cd #{name} && crystal deps update`
          end
        end
      when "scaffold"
        # puts "Rendering Scaffold #{name}"
        puts "=" * 60
        puts "SCAFFOLD"
        # puts @api
        puts "=" * 60
        Scaffold.new(name, fields).render(directory, list: true, color: true)
      when "model"
        puts "Rendering Model #{name}"
        Model.new(name, fields).render(directory, list: true, color: true)
      when "controller"
        puts "Rendering Controller #{name}"
        Controller.new(name, fields).render(directory, list: true, color: true)
      when "migration"
        puts "Rendering Migration #{name}"
        Migration.new(name, fields).render(directory, list: true, color: true)
      when "mailer"
        puts "Rendering Mailer #{name}"
        Mailer.new(name, fields).render(directory, list: true, color: true)
      when "socket"
        puts "Rendering Socket #{name}"
        if fields != [] of String
          fields.each do |field|
            WebSocketChannel.new(field).render(directory, list: true, color: true)
          end
        end
        WebSocket.new(name, fields).render(directory, list: true, color: true)
      when "channel"
        puts "Rendering Channel #{name}"
        WebSocketChannel.new(name).render(directory, list: true, color: true)
      when "auth"
        puts "Rendering Auth #{name}"
        Auth.new(name, fields).render(directory, list: true, color: true)
      else
        raise "Template not found"
      end
    end
  end
end

class Teeplate::RenderingEntry
  def appends?
    @data.path.includes?("+")
  end

  def forces?
    appends? || @data.forces? || @renderer.forces?
  end

  def local_path
    @local_path ||= if appends?
                      @data.path.gsub("+", "")
                    else
                      @data.path
                    end
  end

  def list(s, color)
    print s.colorize.fore(color).toggle(Amber::CLI.color)
    puts local_path
  end
end

module Teeplate
  abstract class FileTree
    # Renders all collected file entries.
    #
    # For more information about the arguments, see `Renderer`.
    def render(out_dir, force : Bool = false, interactive : Bool = false, interact : Bool = false, list : Bool = false, color : Bool = false, per_entry : Bool = false, quit : Bool = true)
      puts "=" * 60
      puts "RENDER"
      puts out_dir
      puts "=" * 60
      renderer = Renderer.new(out_dir, force: force, interact: interactive || interact, list: list, color: color, per_entry: per_entry, quit: quit)
      puts "=" * 60
      puts "FILE ENTRIES"
      # puts file_entries
      puts "=" * 60
      renderer << filter(file_entries)
      renderer.render
      renderer
    end

    # Override to filter files rendered
    def filter(entries)
      entries
    end
  end
end
