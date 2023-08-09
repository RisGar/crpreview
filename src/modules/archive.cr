require "digest/md5"
require "colorize"
require "../libs/archive"

# Handles archive parsing and printing.
module Archive
  include Clibs
  alias Status = LibArchive::ArchiveStatus

  HALF_YEAR = 31_536_000

  # Returns the content of an archive by reading from cache or calling `#cache_archive` to generate the cache.
  def archive(file_name : String) : String
    s = File.info(file_name)
    hash = Digest::MD5.hexdigest do |ctx|
      ctx.update file_name
      ctx.update s.size.to_s
      ctx.update s.modification_time.to_unix.to_s
    end
    cache = "#{ENV["HOME"]}/.cache/crpreview/archive.#{hash}"
    if !File.exists?(cache + ".txt")
      cache_archive(file_name, cache + ".txt")
    else
      File.read(cache + ".txt")
    end
  end

  # Generates the cache at a path for an archive and returns the string so the cache doesn't have to be read again.
  def cache_archive(file_name : String, cache_file : String) : String
    archive = LibArchive.archive_read_new
    archive_entry = uninitialized LibArchive::ArchiveEntry*

    LibArchive.archive_read_support_filter_all(archive)
    LibArchive.archive_read_support_format_all(archive)

    r = LibArchive.archive_read_open_filename(archive, file_name.to_unsafe, 10240) # TODO: blocksize?
    raise "ERROR: Couldn't open specified archive" if r != Status::ARCHIVE_OK

    strmodes = [] of String
    sizes = [] of Int64
    names = [] of String
    mtimes = [] of Int64
    while LibArchive.archive_read_next_header(archive, pointerof(archive_entry)) == Status::ARCHIVE_OK
      strmodes.push String.new(LibArchive.archive_entry_strmode(archive_entry))
      names.push String.new(LibArchive.archive_entry_pathname_utf8(archive_entry))
      sizes.push LibArchive.archive_entry_size(archive_entry)
      mtimes.push LibArchive.archive_entry_mtime(archive_entry)
    end

    sizes_raw = sizes.map_with_index { |s, i|
      if strmodes[i].starts_with?("d")
        "-"
      elsif s < 1000
        s.humanize(precision: 0, significant: false)
      else
        s.humanize
      end
    }
    sizes_width = sizes_raw.max_of(&.size)
    sizes_colorised = sizes_raw.map { |s|
      case s
      when "-"
        s.colorize(:light_gray).to_s
      when .ends_with?(/[^0-9]/)
        s.rchop.colorize(:light_green).to_s + s[-1].colorize(:green).to_s
      else
        s.colorize(:light_green).to_s
      end
    }

    mtimes_colorised = mtimes.map { |t|
      now = Time.local.to_unix
      if t < now - HALF_YEAR || t > now + HALF_YEAR
        Time.unix(t).to_s(format: "%e %b  %Y").colorize(:blue).to_s
      else
        Time.unix(t).to_s(format: "%e %b %H:%M").colorize(:blue).to_s
      end
    }

    string = ""
    i = 0
    while i < strmodes.size
      string += strmodes[i] + " "
      string += " " * (sizes_width - sizes_raw[i].size)
      string += sizes_colorised[i] + "  "
      string += mtimes_colorised[i] + "  "
      string += names[i] + "\n"
      i += 1
    end

    LibArchive.archive_read_free(archive)

    File.write(cache_file, string)

    string
  end
end
