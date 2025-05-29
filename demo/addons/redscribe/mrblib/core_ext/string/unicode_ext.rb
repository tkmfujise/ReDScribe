module StringUnicodeExt
  # = Altenative for String#chars
  #
  #   'abcあいう🍣🍺'.chars
  #   # => ['a', 'b', 'c', 'あ', 'い', 'う', '🍣', '🍺']
  #
  def chars
    unpack('U*').map{|a| [a].pack('U*') }
  end
end
