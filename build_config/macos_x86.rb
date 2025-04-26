MRuby::Build.new do |conf|
  conf.toolchain :clang

  conf.gembox 'default'

  conf.cc do |cc|
    cc.flags = ['-arch x86_64']
  end

  conf.linker do |linker|
    linker.flags = ['-arch x86_64']
  end

  conf.enable_bintest
  conf.enable_test
end


