
task :default => :all


task :all => :mruby_build do
  sh 'scons'
end

task :mruby_build do
  cd 'mruby' do
    ENV['CFLAGS'] = '/MT'
    sh 'rake'
  end
end


task :clean do
  cd 'mruby' do
    sh 'rake clean'
  end
end
