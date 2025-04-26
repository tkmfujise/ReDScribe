MRuby::Build.new do |conf|
  conf.toolchain :clang

  conf.gembox 'default'

  conf.cc do |cc|
    cc.flags = ['-arch arm64']
  end

  conf.linker do |linker|
    linker.flags = ['-arch arm64']
  end

  conf.enable_bintest
  conf.enable_test
end


