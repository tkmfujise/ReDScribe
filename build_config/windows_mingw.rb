MRuby::Build.new do |conf|
  conf.toolchain :gcc

  conf.gembox 'default'

  conf.cc do |cc|
    cc.flags = ['-static']
  end

  conf.cxx do |cxx|
    cxx.flags = ['-static']
  end

  conf.linker do |linker|
    linker.flags = ['-static']
  end

  conf.enable_bintest
  conf.enable_test
end
