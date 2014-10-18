# coding: utf-8

module AdbSdkLib

  # Data representing an image taken from a device frame buffer.
  #
  # This is a wrapper of com.android.ddmlib.RawImage
  class RawImage
    include Common

    # @param [Rjb::Rjb_JavaProxy] RawImage Rjb proxy of com.android.ddmlib.RawImage
    def initialize(image)
      unless image.instance_of?(Rjb::Rjb_JavaProxy) &&
          image._classname == 'com.android.ddmlib.RawImage'
        raise TypeError, "Parameter is not com.android.ddmlib.RawImage class"
      end
      class << image
        def call_java_method(method_name, *args)
          rjb_method_missing(method_name, *args)
        rescue => e
          raise SdkLibError.new(e.message, e.class.to_s, self._classname, method_name)
        end
        alias_method :rjb_method_missing, :method_missing
        alias_method :method_missing, :call_java_method
      end
      @image = image
    end

    # Returns a rotated version of the image
    # The image is rotated counter-clockwise.
    # @return [RawImage] rotated image
    def rotated
      RawImage.new(@image.getRotated())
    end

    # Returns ARGB value of a pixel
    # @param [Fixnum] index of the pixel in data
    # @return [Fixnum] ARGB value of the given pixel
    def get_argb(index)
      @image.getARGB(index)
    end

    # Returns Hash with color values of a pixel
    # @param [Fixnum] index of the pixel in data
    # @return [Hash] color values of the given pixel
    def color(index)
      argb = @image.getARGB(index)
      {
        alpha: (argb >> 8*3) & 0xFF,
        red: (argb >> 8*2) & 0xFF,
        green: (argb >> 8*1) & 0xFF,
        blue: (argb >> 8*0) & 0xFF
      }
    end

    # Returns Hash with color values of a pixel
    # @param [Fixnum, Fixnum] pixel position x,y
    # @return [Hash] color values of the given pixel
    def color_at(x,y)
      color(point_to_index(x,y))
    end

    # Returns image's width
    # @return [Fixnum] image's width
    def width()
      @image.width
    end

    # Returns image's height
    # @return [Integer] image's height
    def height()
      @image.height
    end

    # Returns image's bpp
    # @return [Integer] image's bpp
    def bpp()
      @image.bpp
    end

    # Returns pixel index for a given position
    # @param [Integer, Integer] pixel position x,y
    # @return [Integer] pixel index
    def point_to_index(x,y)
      return (x*(bpp >> 3))+(y*((bpp >> 3)*(width)))
    end
  end
end
