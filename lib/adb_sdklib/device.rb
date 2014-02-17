# coding: utf-8
require 'adb_sdklib/common'
require 'fileutils'

module AdbSdkLib

  # One of android device attached to host through ADB.
  # 
  # This is a wrapper of com.android.ddmlib.Device object in Java.
  class Device
    include Common

    # @param [Rjb::Rjb_JavaProxy] device Rjb proxy object of com.android.ddmlib.Device
    def initialize(device)
      unless device.instance_of?(Rjb::Rjb_JavaProxy) &&
          device._classname == 'com.android.ddmlib.Device'
        raise TypeError, "Parameter is not com.android.ddmlib.Device class"
      end
      class << device
        def call_java_method(method_name, *args)
          rjb_method_missing(method_name, *args)
        rescue => e
          raise SdkLibError.new(e.message, e.class.to_s, self._classname, method_name)
        end
        alias_method :rjb_method_missing, :method_missing
        alias_method :method_missing, :call_java_method
      end
      @device = device
    end

    # @!attribute [r] jobject
    # @return [Rjb::Rjb_JavaProxy] Wrapper of com.android.ddmlib.Device object.
    def jobject;         @device end
    
    # @!attribute [r] serial
    # @return [String] the serial number of the device.
    def serial;          @device.getSerialNumber end
    
    # @!attribute [r] state
    # @return [Symbol] the state of the device.
    #   (:BOOTLOADER, :OFFLINE, :ONLINE, :RECOVERY)
    def state;           @device.getState.toString.to_sym end
    
    # @!attribute [r] online?
    # @return [Boolean] true if the device is ready.
    def online?;         @device.isOnline end
    
    # @!attribute [r] emulator?
    # @return [Boolean] true if the device is an emulator.
    def emulator?;       @device.isEmulator end
    
    # @!attribute [r] offline?
    # @return [Boolean] true if the device is offline.
    def offline?;        @device.isOffline end
    
    # @!attribute [r] bootloader?
    # @return [Boolean] true if the device is in bootloader mode.
    def bootloader?;     @device.isBootloader end
    
    # Reboot the device
    # @param [String, nil] into the bootloader name to reboot into,
    #   or nil to just reboot the device
    # @return [self]
    def reboot(into=nil) @device.reboot(into); self end
    
    # Returns the property count.
    # @return [Integer] the number of property for this device.
    def property_count;  @device.getPropertyCount end
    
    # Returns a property value.
    # @param [String] name the name of the value to return.
    # @return [String, nil] the value or nil if the property does not exist.
    def property(name);  @device.getProperty(name) end
    
    # Returns the device properties. It contains the whole output of 'getprop'
    # @return [Hash<String, String>] the device properties
    def properties
      convert_map_to_hash(@device.getProperties) do |hash, key, value|
        hash[key.toString] = value.toString
      end
    end

    # the build version of the android on the device.
    # (same as output of 'getprop ro.build.version.release')
    # @!attribute [r] build_version 
    # @return [String] the build version of the android.
    def build_version;   property(@device.PROP_BUILD_VERSION) end

    # the API level of the android on the device.
    # (same as output of 'getprop ro.build.version.sdk')
    # @!attribute [r] api_level
    # @return [String] the API level.
    def api_level;       property(@device.PROP_BUILD_API_LEVEL) end

    # the build code name of the android on the device.
    # @!attribute [r] build_codename
    # (same as output of 'getprop ro.build.version.codename')
    # @return [String] the build code name.
    def build_codename;  property(@device.PROP_BUILD_CODENAME) end

    # the product model of the device.
    # (same as output of 'getprop ro.product.model')
    # @!attribute [r] device_model
    # @return [String] the device model.
    def device_model;    property(@device.PROP_DEVICE_MODEL) end

    # the product manufacturer of the device.
    # (same as output of 'getprop ro.product.manufacturer')
    # @!attribute [r] device_manufacturer
    # @return [String] the product manufacturer.
    def device_manufacturer; property(@device.PROP_DEVICE_MANUFACTURER) end

    # the device debuggable.
    # (same as output of 'getprop ro.debuggable')
    # @!attribute [r] debuggable
    # @return [String] the device debuggable.
    def debuggable;      property(@device.PROP_DEBUGGABLE) end

    # Returns the battery level.
    # @param [Integer] freshness_ms freshness time (milliseconds).
    # @return [Integer] the battery level.
    def battery_level(freshness_ms = nil)
      if freshness_ms.nil?
        @device.getBatteryLevel.intValue
      else
        @device.getBatteryLevel(freshness_ms).intValue
      end
    end
    
    # Executes a shell command on the device, and receives the result.
    # @!method shell(command)
    # @return [String, self]
    # @overload shell(command)
    #   @param [String] command the command to execute
    #   @return [String] all results of the command.
    # @overload shell(command)
    #   @param [String] command the command to execute
    #   @return [self] self
    #   @yield [line]
    #   @yieldparam [String] line each line of results of the command.
    def shell(command, &block)
      capture = CommandCapture.new(block_given? ? block : nil)
      receiver = Rjb::bind(capture, 'com.android.ddmlib.IShellOutputReceiver')
      @device.executeShellCommand(command.to_s, receiver)
      block_given? ? self : capture.to_s
    end

    # Pushes a file to the device.
    # 
    # If *remotefile* path ends with '/', complements by the basename of
    # *localfile*.
    # @example
    #   device = AdbSdkLib::Adb.new.devices.first
    #   device.push('path/to/local.txt', '/data/local/tmp/remote.txt')
    #   device.push('path/to/file.txt', '/data/local/tmp/') # uses file.txt
    # @param [String] localfile the name of the local file to send
    # @param [String] remotefile the name of the remote file or directory
    #   on the device
    # @return [self] self
    # @raise [ArgumentError] If *localfile* is not found
    def push(localfile, remotefile)
      raise ArgumentError, "Not found #{localfile}" unless File.exist?(localfile)
      if remotefile.end_with?('/')
        remotefile = "#{remotefile}#{File.basename(localfile)}"
      end
      @device.pushFile(localfile, remotefile)
      self
    end

    # Pulls a file from the device.
    # 
    # If *localfile* path ends with '/', complements by the basename of
    # *remotefile*.
    # @example
    #   device = AdbSdkLib::Adb.new.devices.first
    #   device.pull('/data/local/tmp/remote.txt', 'path/to/local.txt')
    #   device.pull('/data/local/tmp/file.txt', 'path/to/dir/') # uses file.txt
    # @param [String] remotefile the name of the remote file on the device to get
    # @param [String] localfile the name of the local file or directory
    # @return [self] self
    def pull(remotefile, localfile)
      if localfile.end_with?('/') || File.directory?(localfile)
        localdir = localfile.chomp('/')
        localfilename = nil
      else
        localdir = File.dirname(localfile)
        localfilename = File.basename(localfile)
      end
      unless File.exist?(localdir)
        FileUtils.mkdir_p(localdir)
      end
      
      localfilename = File.basename(remotefile) if localfilename.nil?
      @device.pullFile(remotefile, "#{localdir}/#{localfilename}")
      self
    end

    # Calls wrapping java object's same name method with arguments.
    # @param [String] method_name method name to call
    # @param [Array] args arguments
    # @return [Object] result of the method call
    def method_missing(method_name, *args)
      return @device.__send__(method_name, *args)
    end

    # Converts self to string.
    # @return [String] convert to string
    def to_s; "Android:#{self.serial}" end

    # Returns the human-readable formatted information.
    # @return [String] the human-readable formatted information
    def inspect; "#<AdbSdkLib::Device:#{self.serial}>" end

    private
    # @private
    def to_ary; nil end
  end
end
