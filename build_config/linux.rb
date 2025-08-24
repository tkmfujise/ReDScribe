MRuby::Build.new do |conf|
  conf.toolchain :gcc

  conf.gembox 'default'

  conf.cc do |cc|
    cc.flags = ['-fPIC']
  end

  conf.cxx do |cxx|
    cxx.flags = ['-fPIC']
  end

  conf.linker do |linker|
    linker.flags = ['-fPIC']
  end

  conf.enable_bintest
  conf.enable_test
end


