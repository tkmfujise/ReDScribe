
task :default => :all


task :all => :mruby_build do
  sh 'scons'
end

task :mruby_build do
  cd 'mruby' do
    ENV['CFLAGS'] = '/MT'
    sh 'rake clean'
    sh 'rake'
  end
end
