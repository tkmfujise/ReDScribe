
# sh 'ls'
def sh(command, *args)
  send(:`, "#{command} #{args.join(' ')}").chomp
end

def ls(*args)
  result = sh "ls #{args.join(' ')}"
  if (result.empty? || \
    (windows? && result.end_with?('No such file or directory'))
  )
    raise "ls: #{args.last}: No such file or directory"
  else
    result
  end
end

def cat(path)
  result = sh "cat #{path}"
  if (result.empty? || \
    (windows? && result.end_with?('No such file or directory'))
  )
    raise "cat: #{path}: No such file or directory"
  else
    result
  end
end

def pwd
  Dir.pwd
end

def cd(dir, &block)
  before = pwd
  Dir.chdir(dir)
  if block_given?
    result = yield
    Dir.chdir(before)
    result
  else
    pwd
  end
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
