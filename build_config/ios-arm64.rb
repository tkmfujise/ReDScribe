sdk_path = `xcrun --sdk iphoneos --show-sdk-path`.strip
raise 'iphoneos SDK is required' if sdk_path.empty?

min_version = ENV.fetch('IOS_DEPLOYMENT_TARGET', '13.0')
flags = [
  '-arch', 'arm64',
  '-isysroot', sdk_path,
  "-miphoneos-version-min=#{min_version}",
  '-fPIC'
]

MRuby::Build.new do |conf|
  conf.toolchain :clang
  conf.gembox 'default'
end

MRuby::CrossBuild.new('ios-arm64') do |conf|
  conf.toolchain :clang
  conf.gembox 'default'

  conf.cc.flags << flags
  conf.cxx.flags << flags
  conf.linker.flags << flags

  conf.exts.object = '.o'
  conf.exts.library = '.a'
end
