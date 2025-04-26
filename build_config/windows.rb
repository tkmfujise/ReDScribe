MRuby::Build.new do |conf|
  conf.toolchain :visualcpp

  conf.gembox 'default'

  conf.cc do |cc|
    cc.flags = ['/MT']
  end

  conf.enable_bintest
  conf.enable_test
end

