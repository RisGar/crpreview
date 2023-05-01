require "digest/md5"

require "./image_renderer"
require "./archive_parser"

# Main module for all code parsing input, processing files or binding to libraries.
module Crpreview
  extend self

  if ARGV.size <= 0
    exit 1
  end

  file = ARGV[0]

  VERSION = "0.2.0"
  USAGE   = "usage: crpreview [-v|--version] [-h|--help] [file]"

  case file
  when "-h" || "--help"
    print USAGE
    exit
  when "-v" || "--version"
    puts "crpreview #{VERSION}"
    puts "Copyright (C) 2023 Rishab Garg"
    puts "Licensed under the EUPL-1.2"
    exit
  end

  if !File.exists?(file)
    puts "ERROR: File does not exist."
    puts USAGE
    exit 1
  end

  def image(file_name : String) : String
    width = ARGV.size > 2 ? ARGV[1].to_i - 5 : 160
    height = ARGV.size > 2 ? ARGV[2].to_i : 40

    config = CanvasConfig.new(width, height)
    canvas = Canvas.new(config)
    image = ImageData.new(file_name)
    canvas.draw_all_pixels(image.pixels, image.width.to_i, image.height.to_i, image.rowstride.to_i)
    output = canvas.print

    canvas.close
    config.close

    output
  end

  def tar(file_name : String) : String
    tar = Archive.new(file_name)
    output = tar.print
    tar.close
    output
  end

  def pdf(file_name : String) : String
    s = File.info(file_name)
    Digest::MD5.hexdigest do |ctx|
      ctx.update file_name
      ctx.update s.size.to_s
      ctx.update s.modification_time.to_unix.to_s
    end
    cache = "#{ENV["HOME"]}/.cache/lf/thumbnail.#{hash}"

    if !File.exists?(cache + ".jpg")
      `pdftoppm -jpeg -f 1 -singlefile "#{file_name}" "#{cache}"`
    end

    image(cache + ".jpg")
  end

  # Overrides for endings not covered by mime-type
  case file
  when /.tar.lrz$/
    print tar(file)
    exit
  when /.md$/
    # print `glow "#{file}"` -> Fix glow showing without colours
    print `bat -pp --color always --wrap character --  "#{file}"`
    exit
  end

  type = `file -b --mime-type "#{file}"`

  # puts type

  case type
  when /^image/ # Images
    print image(file)
  when /inode\/directory/ # Directories
    print `exa -a --color=always --group-directories-first --icons "#{file}"`
  when /x-tar$|x-7z-compressed$|zip$|x-bzip$|x-bzip2$|gzip$|x-xz$|zstd$|x-lzip$/ # Archives
    print tar(file)
  when /application\/pdf/ # PDFs
    print pdf(file)
  when /application\/octet-stream/ # Binaries
    print "binary data"
  else # Others (text, etc.)
    print `bat -pp --color always --wrap character -- "#{file}"`
  end
end
