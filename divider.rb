class Divider

    class Point
        attr_reader :x
        attr_reader :y

        def initialize(x, y)
            @x = x
            @y = y
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

    class Segment
        attr_reader :start_point
        attr_reader :end_point

        def initialize(start_point, end_point)
            @start_point = start_point
            @end_point = end_point
        end

    end

    class Polygon
        attr_reader :segments
        attr_reader :vertices
        attr_reader :midpoint

        def initialize(segments)
            @segments = segments
            @vertices = segments.map { |seg| seg.start_point }
            @midpoint = @vertices.inject { |sum, pnt| sum + pnt } / @vertices.size
        end

        def contains?(point)
            return true
        end

    end

    def initialize(min_x=0, min_y=0, max_x=0, max_y=0)
        bounds = [[min_x, min_y], [max_x, min_y], [max_x, max_y], [min_x, max_y] ]
        points = bounds.map { |x, y| Point.new(x, y) }
        @polygons = [polygon_from_vertices(points)]
    end

    def run
        n = 10 #rand?
        n.times do
            polygon = @polygons.delete_at(rand(@polygons.size))
            split(polygon)
        end
        return @polygons
    end

    def polygon_from_vertices(vertices)
        segments = vertices.zip(vertices.rotate(1)).map { |p1, p2| Segment.new(p1, p2) }
        return Polygon.new(segments)
    end

    def split(polygon)
        # pick a subset of the vertices, and add some in between the two ends
        start_vertex_index = rand(polygon.vertices.size)
        vertex_count = polygon.vertices.size / 2
        sub_polygon_1 = polygon.vertices.rotate(start_vertex_index)[0...vertex_count]
        sub_polygon_2 = polygon.vertices - sub_polygon_1
        min_x = polygon.vertices.min { |v| v.x }.x
        min_y = polygon.vertices.min { |v| v.y }.y
        max_x = polygon.vertices.max { |v| v.x }.x
        max_y = polygon.vertices.max { |v| v.y }.y
        border = []
        begin
            x = min_x + rand(max_x - min_x)
            y = min_y + rand(max_y - min_y)
            point = Point.new(x, y)
            until polygon.contains?(point)
                x = min_x + rand(max_x - min_x)
                y = min_y + rand(max_y - min_y)
                point = Point.new(x, y)
            end
            border.push(point)
        end
        sub_polygon_2 += border
        sub_polygon_1 += border.reverse
        @polygons.push(polygon_from_vertices(sub_polygon_1))
        @polygons.push(polygon_from_vertices(sub_polygon_2))
    end

end


r = Divider.new(0, 0, 400, 200)
polys = r.run
p polys.size
puts polys.map { |poly| poly.midpoint }