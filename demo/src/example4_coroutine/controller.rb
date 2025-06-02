require 'addons/redscribe/mrblib/coroutine'

module Helper
  def says(str)
    case str
    when Array
      str.each{|s| says(s); ___? }
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
end
Coroutine.include Helper


coroutine 'Woman' do
  asks "Hello traveler! Do you like Ruby?"
  if ___?
    says "Oh! Really? I love Ruby too!"
  else
    says ["Oh, I see. If you haven't used Ruby much,",
          "Spend more time with it. I'm sure you'll love it!"]
  end
  puts ___
end


coroutine 'Man' do
  asks "Which one would you like?", {
    jrpg:    "JRPG",
    act_adv: "Action-Adventure",
    pokemon: "Pokémon",
  }
  case ___?
  when :jrpg
    says "MOTHER2 is my origin."
  when :act_adv
    says "The Legend of Zelda is a huge part of my life."
  when :pokemon
    says "When our eyes meet, it's time for a Pokémon battle!"
    battle!
  end
  puts ___
end


coroutine 'Ninja' do
  says "..."
end
