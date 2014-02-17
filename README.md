# adb-sdklib

Android Debug Bridge (ADB) wrapper using Android SDK Tools Library with Rjb

## Installation
```bash
# Install Rjb
$ export JAVA_HOME=<your java home path>
$ gem install rjb

# Install adb-sdklib
$ gem install adb-sdklib
```

## Usage

### Adb Object

```ruby
require 'adb-sdklib'
adb = AdbSdkLib::Adb.new
# If 'adb' command-line tool isn't in your $PATH, set adb location to constructor shown as below
# adb = AdbSdkLib::Adb.new(<adb location>)

# Get device objects
devices = adb.devices
```

**Adb** object is wrapper of *com.android.ddmlib.AndroidDebugBridge*.  
Source code of *com.android.ddmlib.AndroidDebugBridge*:
<https://android.googlesource.com/platform/tools/base/+/master/ddmlib/src/main/java/com/android/ddmlib/AndroidDebugBridge.java>

Some methods of *AndroidDebugBridge* are wrapped for Ruby.  
For remaining methods, *Adb#method_missing* is defined to call
wrapping java object's same name method using specified parameters.

### Device Object

```ruby
adb = AdbSdkLib::Adb.new
device = adb.devices.first
# device = adb.devices['xxxxxx'] # get by serial number of the device.
puts <<"EOS"
serial    : #{device.serial}
state     : #{device.state}
emulator  : #{device.emulator?}
build ver : #{device.build_version}
api level : #{device.api_level}
device model  : #{device.device_model}
manufacturer  : #{device.manufacturer}
build desc    : #{device.property('ro.build.description')}
battery level : #{device.battery_level}
EOS
```

**Device** object is wrapper of *com.android.ddmlib.Device*.  
Source code of *com.android.ddmlib.Device*:
<https://android.googlesource.com/platform/tools/base/+/master/ddmlib/src/main/java/com/android/ddmlib/Device.java>

Some methods of *ddmlib.Device* are wrapped for Ruby.
For remaining methods, *Device#method_missing* is defined to call
wrapping java object's same name method using specified parameters.

## Contributing

1. Fork it ( http://github.com/yoyo0906/ruby-adb-sdklib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

- MIT License
- Copyright (c) 2014 yoyo0906
