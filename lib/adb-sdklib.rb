# coding: utf-8
require "adb_sdklib/version"
require 'adb_sdklib/common'
require 'adb_sdklib/device'

module AdbSdkLib
  # List of devices.
  # It can be used as Enumerable like Set, and as Hash which key
  #   is the serial number of the device.
  class DeviceList < Hash
    # @param [Enumerable] devices Device object of Java
    def initialize(devices = [])
      devices.each { |d| self[d.serial_number] = d }
    end
    # Calls block once for each device in self, passing that device as a parameter.
    # If no block is given, an enumerator is returned instead.
    # @return [Enumerator] if not block given
    # @return [self] if block given
    # @yield [device] called with each device
    # @yieldparam [Device] device a device instance
    def each
      return self.values.each unless block_given?
      self.values.each {|device| yield device }
      return self
    end
  end
  
  class Adb
    include Common

    # @private
    @@java_initialized = false

    # @private
    # AndroidDebugBridge class object
    @@adb = nil

    # Initialize Rjb and connect to ADB.
    # @param [String] adb_location Location of ADB command line tool
    # @param [Boolean] force_new_bridge if set true, start force new ADB server
    # @raise [AdbError] If could not found ADB command line tool
    def initialize(adb_location = nil, force_new_bridge = false)
      if adb_location.nil?
        @adbpath = `which adb`.chomp!
        raise AdbError, "Not found 'adb' command in $PATH" unless @adbpath
      else
        @adbpath = adb_location
        raise AdbError, "Not found 'adb' command" unless @adbpath
      end

      # load jar files
      unless @@java_initialized
        load_sdk_tools_jar(['ddmlib.jar'])
        # Hide logs to be output to the console.
        ddm = Rjb::import('com.android.ddmlib.DdmPreferences')
        ddm.setLogLevel('assert')
        @@java_initialized = true
        at_exit { Adb.terminate }
      end
      if @@adb.nil?
        @@adb = Rjb::import('com.android.ddmlib.AndroidDebugBridge')
        @@adb.initIfNeeded(false)
      end

      @adb = @@adb.createBridge(@adbpath, force_new_bridge)
      10.times { |i|
        break if @adb.connected?
        sleep(0.25)
      }
      raise AdbError, 'Connect adb error (timeout)' unless @adb.connected?
      
      @devices = DeviceList.new
    end

    # Terminate ADB connection.
    # This method will be called automatically when exiting ruby.
    # @return [self] self
    def self.terminate
      unless @@adb.nil?
        @@adb.terminate
        @@adb = nil
      end
      self
    end

    # Get devices attached with ADB.
    # @return [DeviceList] List of devices
    def devices
      devices = @adb.devices.map { |d|
        serial = d.serial_number
        (@devices.has_key?(serial) && same_jobject?(@devices[serial].jobject, d)) \
          ? @devices[serial] : Device.new(d)
      }
      @devices = DeviceList.new(devices)
      return @devices
    end

    private
    
    # @private
    def load_sdk_tools_jar(libs)
      libpath = File.expand_path('../tools/lib/', File.dirname(@adbpath))
      libs.each do |lib|
        lib = "#{libpath}/#{lib}"
        raise AdbError, "Not found #{lib}" unless File.exist?(lib)
        Rjb::add_jar(lib)
      end
    end
  end
end
