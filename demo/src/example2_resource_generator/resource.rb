require 'src/example2_resource_generator/schema'

chapter 'First' do
  number 1
  music  'first_chapter.mp3'

  image do
    path 'assets/images/icon.svg'
  end

  (1..3).map do |i|
    stage do
      name  "Stage#{i}"
      image do
        "assets/images/stage_#{i}.svg"
      end
    end
  end
end
