# no code, bruh

#############
#...........#
###B#A#A#D###
  #D#C#B#C#
  #########

energy = 0

#############
#Axxxx......#
###B#x#A#D###
  #D#C#B#C#
  #########

energy += 5

#############
#AAxxxxx....#
###B#.#x#D###
  #D#C#B#C#
  #########

energy += 6

#############
#AA.Bxxx....#
###B#.#x#D###
  #D#C#x#C#
  #########

energy += 50

#############
#AA.Bxxx....#
###B#x#x#D###
  #D#x#C#C#
  #########

energy += 600

#############
#AA.xx......#
###B#x#.#D###
  #D#B#C#C#
  #########

energy += 30

#############
#AAxxx......#
###x#B#.#D###
  #D#B#C#C#
  #########

energy += 40

#############
#AA......xD.#
###.#B#.#x###
  #D#B#C#C#
  #########

energy += 2000

#############
#AA....xxxD.#
###.#B#C#x###
  #D#B#C#x#
  #########

energy += 500

#############
#AAxxxxxxxD.#
###x#B#C#x###
  #x#B#C#D#
  #########

energy += 10000

#############
#AA......xx.#
###.#B#C#D###
  #.#B#C#D#
  #########

energy += 2000

#############
#Axx........#
###x#B#C#D###
  #A#B#C#D#
  #########

energy += 3

#############
#xxx........#
###A#B#C#D###
  #A#B#C#D#
  #########

energy += 3

puts "Part 1: #{energy}"

#############
#...........#
###B#A#A#D###
  #D#C#B#A#
  #D#B#A#C#
  #D#C#B#C#
  #########

energy = 0

#############
#......xxxxA#
###B#A#x#D###
  #D#C#B#A#
  #D#B#A#C#
  #D#C#B#C#
  #########

energy += 5

#############
#Axxxx.....A#
###B#x#.#D###
  #D#C#B#A#
  #D#B#A#C#
  #D#C#B#C#
  #########

energy += 5

#############
#A.....xxxBA#
###B#.#x#D###
  #D#C#x#A#
  #D#B#A#C#
  #D#C#B#C#
  #########

energy += 50

#############
#AAxxxxx..BA#
###B#.#x#D###
  #D#C#x#A#
  #D#B#x#C#
  #D#C#B#C#
  #########

energy += 8

#############
#AA....xB.BA#
###B#.#x#D###
  #D#C#x#A#
  #D#B#x#C#
  #D#C#x#C#
  #########

energy += 50

#############
#AA..xxxB.BA#
###B#x#x#D###
  #D#x#x#A#
  #D#B#x#C#
  #D#C#C#C#
  #########

energy += 800

#############
#AA.Bx..B.BA#
###B#x#.#D###
  #D#x#.#A#
  #D#x#.#C#
  #D#C#C#C#
  #########

energy += 40

#############
#AA.BxxxB.BA#
###B#x#x#D###
  #D#x#x#A#
  #D#x#C#C#
  #D#x#C#C#
  #########

energy += 900

#############
#AA.xx..B.BA#
###B#x#.#D###
  #D#x#.#A#
  #D#x#C#C#
  #D#B#C#C#
  #########

energy += 50

#############
#AAxxx..B.BA#
###x#x#.#D###
  #D#x#.#A#
  #D#B#C#C#
  #D#B#C#C#
  #########

energy += 60

#############
#AA.......BA#
###.#.#.#D###
  #D#B#.#A#
  #D#B#C#C#
  #D#B#C#C#
  #########

energy += 50

#############
#AA..xxxxxxA#
###.#B#.#D###
  #D#B#.#A#
  #D#B#C#C#
  #D#B#C#C#
  #########

energy += 60

#############
#AA...Dxxx.A#
###.#B#.#x###
  #D#B#.#A#
  #D#B#C#C#
  #D#B#C#C#
  #########

energy += 4000

#############
#AA...D..xAA#
###.#B#.#x###
  #D#B#.#x#
  #D#B#C#C#
  #D#B#C#C#
  #########

energy += 3

#############
#AA...DxxxAA#
###.#B#x#x###
  #D#B#C#x#
  #D#B#C#x#
  #D#B#C#C#
  #########

energy += 700

#############
#AA...DxxxAA#
###.#B#C#x###
  #D#B#C#x#
  #D#B#C#x#
  #D#B#C#x#
  #########

energy += 700

#############
#AA...xxxxAA#
###.#B#C#x###
  #D#B#C#x#
  #D#B#C#x#
  #D#B#C#D#
  #########

energy += 7000

#############
#AAxxxxxxxAA#
###x#B#C#x###
  #x#B#C#x#
  #D#B#C#D#
  #D#B#C#D#
  #########

energy += 11000

#############
#AAxxxxxxxAA#
###x#B#C#x###
  #x#B#C#D#
  #x#B#C#D#
  #D#B#C#D#
  #########

energy += 11000

#############
#AAxxxxxxxAA#
###x#B#C#D###
  #x#B#C#D#
  #x#B#C#D#
  #x#B#C#D#
  #########

energy += 11000

#############
#Axx......AA#
###x#B#C#D###
  #x#B#C#D#
  #x#B#C#D#
  #A#B#C#D#
  #########

energy += 5

#############
#xxx......AA#
###x#B#C#D###
  #x#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########

energy += 5

#############
#..xxxxxxxxA#
###x#B#C#D###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########

energy += 9

#############
#..xxxxxxxxx#
###A#B#C#D###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########

energy += 9

puts "Part 2: #{energy}"
