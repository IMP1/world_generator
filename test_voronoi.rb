require_relative 'voronoi'

MIN_X = 10
MIN_Y = 10
MAX_X = 1000
MAX_Y = 1000

POINTS = []

20.times do
    x = MIN_X + rand(MAX_X - MIN_X)
    y = MIN_Y + rand(MAX_Y - MIN_Y)
    POINTS.push(Voronoi::Point.new(x, y))
end

puts POINTS.map { |p| "(#{p.x}, #{p.y})" }
puts
$stdout.flush

v = Voronoi.new(POINTS, MIN_X, MIN_Y, MAX_X, MAX_Y)

vertices, segments = v.run


# p vertices
# puts
# puts
# p segments
# puts