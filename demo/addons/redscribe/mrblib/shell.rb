
# sh 'ls'
def sh(command, *args)
  send(:`, "#{command} #{args.join(' ')}").chomp
end

%i[ls cat].each do |sym|
  define_method(sym) do |*args|
    sh "#{sym} #{args.join(' ')}"
  end
end

def pwd
  Dir.pwd
end

def cd(dir, &block)
  before = pwd
  Dir.chdir(dir)
  result = yield
  Dir.chdir(before)
  result
end

def windows?
  sh('uname').include? 'Windows'
end

def mac?
  sh('uname').include? 'Darwin'
end

def linux?
  sh('uname').include? 'Linux'
end

ENV = begin
  sh('env').split.map{|s|
    arr = s.split('=')
    [arr[0], arr[1..-1].join('=')]
  }.to_h
rescue
  {}
end
