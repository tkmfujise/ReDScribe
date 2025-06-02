require 'src/example4_coroutine/helper'

$people_spoken = Set.new


coroutine 'Woman' do
  asks "Hi! Do you like Ruby?"
  if ___?
    says "Oh! Really? I love Ruby too!"
  else
    says ["Oh, I see. If you haven't used Ruby much,",
          "spend more time with it. I'm sure you'll love it!"]
  end
  $people_spoken.add(name)
end


coroutine 'Man' do
  asks "Which one would you like?", {
    jrpg:    "JRPG",
    act_adv: "Action-Adventure",
    pokemon: "Pokémon",
  }
  case ___?
  when :jrpg
    says "I'm also love it. MOTHER2 is my origin."
  when :act_adv
    says "I'm also love it. The Legend of Zelda is a huge part of my life."
  when :pokemon
    says "When our eyes meet, it's time for a Pokémon battle!"
    battle!
  end
  $people_spoken.add(name)
end


coroutine 'Ninja' do
  if $people_spoken.size < 2
    says ["...", "... #{$people_spoken.size}"]
  else
    says "Nin-nin!"
  end
end
