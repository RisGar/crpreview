require "digest/md5"
require "./clibs/archive"

module Crpreview
  alias Status = LibArchive::ArchiveStatus

  def archive(file_name : String) : String
    s = File.info(file_name)
    hash = Digest::MD5.hexdigest do |ctx|
      ctx.update file_name
      ctx.update s.size.to_s
      ctx.update s.modification_time.to_unix.to_s
    end
    cache = "#{ENV["HOME"]}/.cache/lf/archive.#{hash}"
    if !File.exists?(cache + ".txt")
      archive_gen(file_name, cache + ".txt")
    else
      File.read(cache + ".txt")
    end
  end

  def archive_gen(file_name : String, cache_file : String) : String
    archive = LibArchive.archive_read_new
    archive_entry = uninitialized LibArchive::ArchiveEntry*

    LibArchive.archive_read_support_filter_all(archive)
    LibArchive.archive_read_support_format_all(archive)

    r = LibArchive.archive_read_open_filename(archive, file_name.to_unsafe, 10240) # TODO: blocksize?
    raise "ERROR: Couldn't open specified archive" if r != Status::ARCHIVE_OK

    string = ""
    while LibArchive.archive_read_next_header(archive, pointerof(archive_entry)) == Status::ARCHIVE_OK
      string = string + String.new(LibArchive.archive_entry_pathname_utf8(archive_entry)) + "\n"
    end

    LibArchive.archive_read_free(archive)

    File.write(cache_file, string)

    string
  end
end
