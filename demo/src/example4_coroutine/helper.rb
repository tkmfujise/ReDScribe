require 'addons/redscribe/mrblib/coroutine'

module Helper
  def says(str)
    case str
    when Array
      str[0..-2].each{|s| asks(s, true => 'Continue'); ___? }
      says(str.last)
    else
      emit! :says, [name, str]
    end
  end

  def asks(str, choices = { true => 'Yes', false => 'No' })
    emit! :asks, [name, str, choices]
  end

  def battle!
    emit! :battle, [name]
  end

  def hide!
    emit! :hide, [name]
  end
end
Coroutine.include Helper
