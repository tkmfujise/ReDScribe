ndk_root = ENV['ANDROID_NDK_HOME'] || ENV['ANDROID_NDK_ROOT'] || ENV['ANDROID_NDK_LATEST_HOME']
raise 'ANDROID_NDK_HOME is required' unless ndk_root

host_tag =
  case RUBY_PLATFORM
  when /darwin/
    'darwin-x86_64'
  when /linux/
    'linux-x86_64'
  else
    raise "Unsupported host for Android cross-build: #{RUBY_PLATFORM}"
  end

toolchain = File.join(ndk_root, 'toolchains', 'llvm', 'prebuilt', host_tag, 'bin')
target = 'x86_64-linux-android'
api = '23'
sysroot = File.join(ndk_root, 'toolchains', 'llvm', 'prebuilt', host_tag, 'sysroot')

MRuby::Build.new do |conf|
  conf.toolchain :gcc
  conf.gembox 'default'
end

MRuby::CrossBuild.new('android-x86_64') do |conf|
  conf.toolchain :gcc
  conf.gembox 'default'

  common_flags = [
    "--target=#{target}#{api}",
    "--sysroot=#{sysroot}",
    '-fPIC'
  ]

  conf.cc.command = File.join(toolchain, "#{target}#{api}-clang")
  conf.cc.flags << common_flags

  conf.cxx.command = File.join(toolchain, "#{target}#{api}-clang++")
  conf.cxx.flags << common_flags

  conf.linker.command = File.join(toolchain, "#{target}#{api}-clang")
  conf.linker.flags << common_flags

  conf.archiver.command = File.join(toolchain, 'llvm-ar')
  conf.archiver.archive_options = 'rs %{outfile} %{objs}'

  conf.exts.object = '.o'
  conf.exts.library = '.a'
end
