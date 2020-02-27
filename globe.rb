class Globe

    class Ring

        def initialize(circumference)
            @cells = Array.new(circumference)
        end

        def size
            @cells.size
        end

        def [](i)
            return @cells[i % size]
        end

        def []=(i, v)
            @cells[i % size] = v
        end

        def each(*args, &block)
            return @cells.each(*args, &block)
        end

    end

    def initialize(horizontal_diameter, vertical_diameter)
        @rings = Array.new(vertical_diameter+1)
        (vertical_diameter+1).times do |i|
            # Assuming a sphere for now
            # TODO: get horizontal radius of elipse at height `i`
            r = (vertical_diameter) / 2.0
            h = (i - vertical_diameter / 2).abs
            w = Math.sqrt(r ** 2 - h ** 2)
            circumference = Math::PI * w * 2
            circumference = [1, circumference.to_i].max
            @rings[i] = Ring.new(circumference)
        end
    end

    def each(*args, &block)
        @rings.each(*args, &block)
    end

    def [](i)
        return @rings[i]
    end

    def size
        return @rings.inject(0) { |sum, ring| sum + ring.size }
    end

end