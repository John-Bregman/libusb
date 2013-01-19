#!/usr/bin/env ruby

require 'rubygems'
require 'ffi'

begin
  module LibTest
    extend FFI::Library
    ext = FFI::Platform.windows? ? 'dll' : 'so'
    bundled_dll = File.expand_path("../../lib/libusb-1.0.#{ext}", __FILE__)
    ffi_lib(['libusb-1.0', bundled_dll])
  end
rescue LoadError
  # Unable to load libusb library on this system,
  # so we build our bundled version:

  libusb_dir = Dir[File.expand_path('../../ext/libusbx-*', __FILE__)].first
  root_dir = File.expand_path('../..', __FILE__)
  raise "could not find embedded libusb sources" unless libusb_dir

  old_dir = Dir.pwd
  Dir.chdir libusb_dir
  cmd = "./configure --prefix=#{root_dir} --enable-debug-log && make && make install"
  puts cmd
  system cmd
  raise "libusb build exited with #{$?.exitstatus}" if $?.exitstatus!=0
  Dir.chdir old_dir
end

File.open("Makefile", "w") do |mf|
  mf.puts "# Dummy makefile since libusb-1.0 is usable on this system"
  mf.puts "all install::\n"
end
