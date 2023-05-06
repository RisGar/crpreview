module Clibs
  {% if flag?(:ci) %}
    # Fix for Ubuntu & FreeBSD ci runners
    @[Link(ldflags: "`pkg-config --cflags --libs MagickWand`")]
  {% else %}
    @[Link("magickwand")]
  {% end %}
  lib LibMagick
    type MagickWand = Void

    enum StorageType
      UndefinedPixel; CharPixel; DoublePixel
      FloatPixel; LongPixel; LongLongPixel
      QuantumPixel; ShortPixel
    end

    fun genesis = MagickWandGenesis
    fun new_wand = NewMagickWand : MagickWand*
    fun read_image = MagickReadImage(wand : MagickWand*, filename : LibC::Char*) : Bool
    fun get_width = MagickGetImageWidth(wand : MagickWand*) : LibC::SizeT
    fun get_height = MagickGetImageHeight(wand : MagickWand*) : LibC::SizeT
    fun export_pixels = MagickExportImagePixels(wand : MagickWand*, x : LibC::SSizeT, y : LibC::SSizeT, width : LibC::SizeT,
                                                height : LibC::SizeT, map : LibC::Char*, storage : StorageType, pixels : Void*) : Bool
    fun destroy_wand = DestroyMagickWand(wand : MagickWand*) : MagickWand*
    fun wand_terminus = MagickWandTerminus : Void
  end
end
