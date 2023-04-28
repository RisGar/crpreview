require "./image_renderer"

module Crpreview
  # darwin/bsd or GNU syste` commands
  stat = ""
  tar = ""
  {% if flag?(:darwin) %}
    stat = "stat -f '%N%i%T%z%B%m'"
    tar = "tar"
  {% elsif flag?(:bsd) %}
    stat = "stat -f '%N%i%T%z%B%m'"
    tar = "tar"
  {% elsif flag?(:gnu) %}
    stat = "stat  --printf '%n%i%F%s%W%Y'"
    tar = "bsdtar"
  {% else %}
    print "ERROR: Unknown system. Please make sure your system is supported by this previewer."
    exit
  {% end %}

  # -v flag
  VERSION = "0.2.0"
  if ARGV.size > 0 && (ARGV[0] == "-v" || ARGV[0] == "--version")
    puts "crpreview #{VERSION}"
    puts "Copyright (C) 2023 Rishab Garg"
    puts "Licensed under the EUPL-1.2"
    exit
  end

  # arguments
  file = ARGV[0]
  width = ARGV.size > 2 ? ARGV[1].to_i : 160
  height = ARGV.size > 2 ? ARGV[2].to_i : 40

  class Image
    @width : Int32
    @height : Int32

    def initialize(width : Int32, height : Int32)
      @width = width - 5
      @height = height
    end

    def chafa(file_path : String)
      config = CanvasConfig.new(@width, @height)
      canvas = Canvas.new(config)
      image = Loader.new(file_path)
      canvas.draw_all_pixels(image.pixel_type, image.pixels, image.width, image.height, image.rowstride)

      print canvas.print
    end
  end

  case file
  when /.tar.lrz$/
    print `#{tar} -tvf "#{file}"`
    exit
  when /.md$/
    # print `glow "#{file}"`
    print `bat -pp --color always --wrap character --  "#{file}"`
    exit
  end

  type = `file -b --mime-type "#{file}"`

  case type
  when /^image/
    image = Image.new(width, height)
    image.chafa(file)
  when /inode\/directory/
    print `exa -a --color=always --group-directories-first --icons "#{file}"`
  when /x-tar$|x-7z-compressed$|zip$|x-bzip$|x-bzip2$|gzip$|x-xz$|zstd$|x-lzip$/
    print `#{tar} -tvf "#{file}"`
  when /application\/pdf/
    hash = `#{stat} -- "#{file}" | sha256sum`.split(' ')[0]
    cache = "#{ENV["HOME"]}/.cache/lf/thumbnail.#{hash}"

    `[ ! -f "#{cache}.jpg" ] && pdftoppm -jpeg -f 1 -singlefile "#{file}" "#{cache}"`
    image = Image.new(width, height)
    image.chafa("#{cache}.jpg")
  when /application\/octet-stream/
    print "binary data"
  else
    print `bat -pp --color always --wrap character -- "#{file}"`
  end
end
