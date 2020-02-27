require_relative 'globe'

class Tectonics

    class Point
        attr_reader :x
        attr_reader :y
        attr_accessor :split_probability

        def initialize(x, y, split_probability=0)
            @x = x
            @y = y
            @split_probability = split_probability
        end

        def +(point)
            return Point.new(@x + point.x, @y + point.y)
        end

        def /(factor)
            return Point.new(@x / factor, @y / factor)
        end

        def to_s
            return "(#{x}, #{y})"
        end

    end

    class FaultLine

        attr_reader :points

        def initialize(start_point)
            @points = [start_point]
        end

        def loop?
            return start_point == end_point && @points.size > 1
        end

        def start_point
            @points.last
        end

        def end_point
            @points.last
        end

    end

    def beta(n, a, b)
        constant = Math.gamma(a + b) / (Math.gamma(a) * Math.gamma(b))
        result = n.times.map { @rng.rand }.map { |x| 
            constant * (x ** (a - 1)) * ((1 - x) ** (b - 1))
        }
        return result
    end

    def initialize(width, height, rng=Random.new)
        @rng = rng
        @globe = Globe.new(width, height)
        puts
        p @globe.size
        # generate a grid of random probabilities
        # shape this grid to better represent a globe
    end
    
    def generate
        a = @rng.rand
        b = @rng.rand
        split_probability_dist = beta(@globe.size, a, b)
        @globe.each do |ring|
            ring.each do |cell| 

            end
        end
        @globe
    end

end


def to_seed(string)
    return string.split(//).map { |chr| chr.ord.to_s }.join.to_i
end

seed = to_seed("lome")
r = Random.new(seed)
t = Tectonics.new(20, 10, r)
p t.generate