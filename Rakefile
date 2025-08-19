require 'dotenv/tasks'
require 'tempfile'
require 'ostruct'

task :default => :all


task :all => :mruby_build do
  sh 'scons'
end

task :release => :mruby_build do
  sh 'scons target=template_release'
end

task :mruby_build do
  def build_config(name = nil)
    if name
      ENV['MRUBY_CONFIG'] = "../../build_config/#{name}"
    else
      ENV['MRUBY_CONFIG'] = nil
    end
    sh 'rake'
  end

  cd 'mruby' do
    case RbConfig::CONFIG['host_os']
    when /mswin|mingw|cygwin/
      build_config 'windows'

    when /darwin/
      libmruby_path = 'build/host/lib/libmruby.a'
      next if File.exist? libmruby_path
      arm64_file = Tempfile.new('libmruby_arm64')
      x86_file   = Tempfile.new('libmruby_x86')
      # arm64_file = OpenStruct.new(path: '/tmp/libmruby_arm64.a').tap{|s| `touch #{s}` }
      # x86_file   = OpenStruct.new(path: '/tmp/libmruby_x86.a').tap{|s| `touch #{s}` }

      build_config 'macos_arm64'
      mv libmruby_path, arm64_file.path

      sh 'rake clean'

      build_config 'macos_x86'
      mv libmruby_path, x86_file.path

      sh "lipo -create -output #{libmruby_path} #{arm64_file.path} #{x86_file.path}"
    when /linux/
      build_config # TODO
    else
      build_config # TODO
    end
  end
end


task :clean do
  cd 'mruby' do
    sh 'rake clean'
  end
end


desc 'Generate doc_classes/*'
task :doc do
  cd 'demo' do
    sh 'godot --doctool ../ --gdextension-docs'
  end
end


task :update do
  sh 'git submodule update --remote --recursive'
end


task apple_cert: :dotenv do
  dylib_paths = Dir['bin/**/libredscribe*.universal']
  dylib_paths.each do |path|
    puts "codesign --sign xxx #{path}"
    %x[ codesign --remove-signature #{path} ]
    %x[
      codesign -s '#{ENV['APPLE_DEV_CERT_NAME']}' \
        --options runtime \
        --timestamp \
        #{path}
    ]
  end
  archive_path = 'tmp/redscribe_release.zip'
  release_path = dylib_paths.find{|p| p.include? 'template_release' }
  puts "creating zip: #{archive_path}"
  %x[
    ditto -ck -rsrc --sequesterRsrc --keepParent \
      '#{release_path}' '#{archive_path}'
  ]
  puts "xcrun notarytool submit"
  output = %x[
      xcrun notarytool submit #{archive_path} \
        --apple-id '#{ENV['APPLE_DEV_ID']}'  \
        --team-id '#{ENV['APPLE_DEV_TEAM_ID']}'  \
        --password '#{ENV['APPLE_CERT_PASSWORD']}'  \
        --wait
    ]
  puts output

  log_id = output[/((\d|[a-z])+-(\d|[a-z])+-(\d|[a-z])+-(\d|[a-z])+-(\d|[a-z])+)/, 1]
  if log_id
    puts "xcrun notarytool log"
    ENV['LOG_ID'] = log_id
    Rake::Task['apple_cert_log'].invoke
  end
end


task apple_cert_log: :dotenv do
  puts %x[
    xcrun notarytool log #{ENV['LOG_ID']} \
      --apple-id '#{ENV['APPLE_DEV_ID']}' \
      --team-id '#{ENV['APPLE_DEV_TEAM_ID']}' \
      --password '#{ENV['APPLE_CERT_PASSWORD']}'
  ]
end


task apple_cert_history: :dotenv do
  puts %x[
    xcrun notarytool history \
      --apple-id '#{ENV['APPLE_DEV_ID']}' \
      --team-id '#{ENV['APPLE_DEV_TEAM_ID']}' \
      --password '#{ENV['APPLE_CERT_PASSWORD']}'
  ]
end


desc 'create addon zip'
task :package do
  src_path = ['demo/', 'addons/redscribe']
  zip_path = ['../', 'tmp/addons.tar.gz']

  cd src_path[0] do
    sh "COPYFILE_DISABLE=1 tar cfz #{zip_path.join} --exclude='.DS_Store' #{src_path[1]}"
  end

  puts "=> #{zip_path[1]}"
end
