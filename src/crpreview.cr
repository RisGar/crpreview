# TODO: Write documentation for `Crpreview`
module Crpreview
  # darwin/bsd or GNU system commands
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

  file = ARGV[0]

  class Image
    def initialize(width : String, height : String)
      @res = "#{width.to_i - 5}x#{height}"
    end

    def symbols(file : String)
      print `chafa "#{file}" -s #{@res} -f symbols`
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
    image = Image.new(ARGV[1], ARGV[2])
    image.symbols(file)
  when /inode\/directory/
    print `exa -a --color=always --group-directories-first --icons "#{file}"`
  when /x-tar$|x-7z-compressed$|zip$|x-bzip$|x-bzip2$|gzip$|x-xz$|zstd$|x-lzip$/
    print `#{tar} -tvf "#{file}"`
  when /application\/pdf/
    hash = `#{stat} -- "#{file}" | sha256sum`.split(' ')[0]
    cache = "#{ENV["HOME"]}/.cache/lf/thumbnail.#{hash}"

    `[ ! -f "#{cache}.jpg" ] && pdftoppm -jpeg -f 1 -singlefile "#{file}" "#{cache}"`
    image = Image.new(ARGV[1], ARGV[2])
    image.symbols("#{cache}.jpg")
  when /application\/octet-stream/
    print "binary data"
  else
    print `bat -pp --color always --wrap character -- "#{file}"`
  end
end
