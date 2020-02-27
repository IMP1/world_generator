=begin

Copyright (c) 2010 David Ng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Based of the work of Steve J. Fortune (1987) A Sweepline Algorithm for Voronoi Diagrams,
Algorithmica 2, 153-174, and its translation to C++ by Matt Brubeck, 
http://www.cs.hmc.edu/~mbrubeck/voronoi.html

=end

require 'ostruct'
require 'prettyprint'

class Numeric

    EPSILON = 0.00001

    def =~(value)
        return (self-value).abs < EPSILON
    end
end

class Heap

    def initialize
        @heap = []
        @nodes = {}
    end

    def []=(k, v)
        raise "Cannot push nil to heap" if v.nil?
        n = @heap.size
        pos = (n - n % 2) / 2
        @heap[n] = k
        @nodes[k] = v
        while n > 1 and @nodes[@heap[pos]] > v do
            @heap[pos], @heap[n] = @heap[n], @heap[pos]
            n = pos
            pos = (n - n % 2) / 2
        end
    end

    def pop
        raise "Cannot pop from empty heap" if @heap.empty?
        @heap[0] = @heap.pop
        @nodes[@heap.first] = nil
        s = @heap.size - 1
        n = 1 # node position in heap array
        p = 2 * n # left sibling position
        if s > p && @nodes[@heap[p]] > @nodes[@heap[p + 1]]
            p = 2 * n + 1 # right sibling position
        end

        while s >= p && @nodes[@heap[p]] < @nodes[@heap[s]]
            @heap[p], @heap[n] = @heap[n], @heap[p]
            n = p
            p = 2 * n
            if s > p && @nodes[@heap[p]] > @nodes[@heap[p + 1]]
                p = 2 * n + 1
            end
        end
        return @heap.first, @nodes[@heap.first]
    end

    def size
        return @heap.size
    end

    def empty?
        return @heap.empty?
    end

end

class DoubleLinkedList

    attr_reader :first
    attr_reader :last

    def initialize
        @first = nil
        @last = nil
    end

    def empty?
        return @first.nil?
    end

    def insert_after(node, data)
        new_node = OpenStruct.new(
            prev: node, 
            next: node.next, 
            x: data.x, 
            y: data.y
        )
        node.next = new_node
        if node == @last
            @last = new_node
        else
            new_node.next.prev = new_node
        end
        return new_node
    end

    def insert_at_start(data)
        new_node = OpenStruct.new(
            prev: nil, 
            next: @first, 
            x: data.x, 
            y: data.y
        )
        if empty?
            @first = new_node
            @last = new_node
        else
            @first.prev = new_node
            @first = new_node
        end
        return new_node
    end

    def each
        current_node = @first
        until current_node.nil?
            yield current_node
            current_node = current_node.next
        end
    end

    def delete(node)
        if node == @first
            @first = node.next
        else
            node.prev.next = node.next
        end

        if node == @last
            @last = node.prev
        else
            node.next.prev = node.prev
        end
    end

    def next_node(node)
        return @first if node.nil?
        return node.next
    end

end

class Voronoi

    class Point
        attr_reader :x
        attr_reader :y

        def initialize(x, y)
            @x = x
            @y = y
        end

    end

    class Segment
        attr_accessor :start_point
        attr_accessor :end_point
        attr_reader :done
        attr_reader :type

        def initialize(start_point, end_point, type=1)
            @start_point = start_point
            @end_point = end_point
            @done = false
            @type = type
        end

        def finish
            @done = true
        end

    end

    class Event < Point
        attr_accessor :arc_node

        def initialize(x, y, arc_node, valid=true)
            super(x, y)
            @arc_node = arc_node
            @valid = valid
        end

        def valid?
            return @valid
        end

        def invalidate
            @valid = false
        end
    end

    def initialize(points, min_x=0, min_y=0, max_x=0, max_y=0)
        @beachline = DoubleLinkedList.new
        @event_heap = Heap.new
        @vertices = []
        @segments = []
        @min = Point.new(min_x, min_y)
        @max = Point.new(max_x, max_y)
        @points_list = points
    end

    def run
        $stdout.sync = true
        puts "Running"
        @points_list.each_with_index do |point, i|
            print "\rPoint: #{i}/#{@points_list.size}"
            # point.x =  point.x + point.dx
            if point.x < @min.x
                point.x = @min.x
                # point.dx = -1 * point.dx
            end
            if point.x > @max.x
                point.x = @max.x
                # point.dx = -1 * point.dx
            end
            
            # point.y =  point.y + point.dy
            if point.y < @min.y
                point.y = @min.y
                # point.dy = -1 * point.dy
            end
            if point.y > @max.y
                point.y = @max.y
                # point.dy = -1 * point.dy
            end
            @event_heap[point] = point.x
        end
        print("\n")

        until @event_heap.empty?
            print "\rHeap size: #{@event_heap.size}"
            e, x = @event_heap.pop
            if e.is_a?(Event)
                process_event(e)
            else
                process_point(e)
            end
        end
        print("\n")
        finish_edges

        return @vertices, @segments
    end

    def process_event(event)
        if event.valid?
            segment = Segment.new(
                Point.new(event.x, event.y), 
                Point.new(0, 0)
            )
            @segments.push(segment)

            @beachline.delete(event.arc_node)

            if event.arc_node.prev
                event.arc_node.prev.segment1 = segment
            end
            if event.arc_node.next
                event.arc_node.next.segment0 = segment
            end

            if event.arc_node.segment0
                event.arc_node.segment0.end_point = Point.new(event.x, event.y)
                event.arc_node.segment0.finish
            end
            if event.arc_node.segment1
                event.arc_node.segment1.end_point = Point.new(event.x, event.y)
                event.arc_node.segment1.finish
            end

            @vertices.push(Point.new(event.x, event.y))

            if event.arc_node.prev
                check_circle_event(event.arc_node.prev, event.x)
            end
            if event.arc_node.next
                check_circle_event(event.arc_node.next, event.x)
            end
            # event.arc_node = nil
        end
    end

    def process_point(point)
        if @beachline.empty?
            @beachline.insert_at_start(point)
            return
        end

        @beachline.each do |arc_node|
            z = intersect(point, arc_node)
            next if z.nil?

            if not (arc_node.next && intersect(point, arc_node.next))
                @beachline.insert_after(arc_node, arc_node)
            else
                return
            end

            arc_node.next.segment1 = arc_node.segment1

            @beachline.insert_after(arc_node, point)

            segment = Segment.new(
                Point.new(z.x, z.y), 
                Point.new(0, 0),
                2
            )
            @segments.push(segment)
            arc_node.next.segment0 = segment
            arc_node.segment1 = segment

            segment = Segment.new(
                Point.new(z.x, z.y), 
                Point.new(0, 0),
                2
            )

            @segments.push(segment)
            arc_node.next.segment0 = segment
            arc_node.segment1 = segment

            check_circle_event(arc_node, point.x)
            check_circle_event(arc_node.next, point.x)
            check_circle_event(arc_node.next.next, point.x)

            return
        end

        @beachline.insert_at_start(point)

        segment = Segment.new(
            Point.new(@min.x, (@beachline.last.y + @beachline.last.prev.y) / 2),
            Point.new(0, 0),
            3
        )
        @segments.push(segment)
        @beachline.last.segment0 = segment
        @beachline.last.prev.segment1 = segment
    end

    def check_circle_event(arc, x0)
        if arc.event and arc.event != x0
            arc.event.invalidate
        end
        arc.event = nil

        return if !arc.prev || !arc.next

        left = arc.prev
        this = arc
        right = arc.next

        if (this.x-left.x)*(right.y-left.y) - (right.x-left.x)*(this.y-left.y) >= 0
            return false
        end   

        # Algorithm from O'Rourke 2ed p. 189.
        a = this.x - left.x
        b = this.y - left.y
        c = right.x - left.x
        d = right.y - left.y
        e = a * (left.x + this.x) + b * (left.y + this.y)
        f = c * (left.x + right.x) + d * (left.y + right.y)
        g = 2 * (a * (right.y - this.y) - b * (right.x - this.x))

        if g == 0
            puts "g is 0"
        end

        centre_x = (d * e - b * f) / g
        centre_y = (a * f - c * e) / g

        radius_squared = (left.x - centre_x) ** 2 + (left.y - centre_y) ** 2
        if radius_squared > 0
            radius = Math.sqrt(radius_squared)
            x = centre_x + radius
            arc.event = Event.new(centre_x, centre_y, arc)
            @event_heap[arc.event] = x
        end
    end

    def intersect(point, arc)
        if arc.x == point.x
            return nil
        end

        if arc.prev
            a = intersection(arc.prev, arc, point.x).y
        end
        if arc.next
            b = intersection(arc, arc.next, point.x).y
        end

        if (arc.prev.nil? || (a <= point.y)) && (arc.next.nil? || (point.y <= b))
            y = point.y
            x = (arc.x**2 + (arc.y-y)**2 - point.x**2) / (2 * arc.x - 2 * point.x)
            return Point.new(x, y)
        end

        return nil
    end

    def intersection(p0, p1, l)
        point = p0
        y = nil

        if p0.x == p1.x
            y = (p0.y + p1.y) / 2
        elsif p1.x == l
            y = p1.y
        elsif p0.x == l
            y = p0.y
            point = p1
        else
            # quadratic formula
            z0 = 2 * (p0.x - l)
            z1 = 2 * (p1.x - l)
            a = 1 / z0 - 1 / z1
            b = -2 * (p0.y / z0 - p1.y / z1)
            c = (p0.y**2 + p0.x**2 - l**2) / z0 - (p1.y**2 + p1.x**2 - l**2) / z1
            b_squared_minus_4ac = b**2 - 4 * a * c
            y = (-b - Math.sqrt(b_squared_minus_4ac.abs)) / (2 * a)
        end

        x = (point.x**2 + (point.y - y)**2 - l**2) / (2 * point.x - 2 * l)
        return Point.new(x, y)
    end

    def finish_edges
        # Advance the sweep line so no parabolas can cross the bounding box.
        l = @max.x + (@max.x - @min.x) + (@max.y - @min.y)

        # Extend each remaining segment to the new parabola intersections.
        @beachline.each do |arc_node|
            next if arc_node.segment1.nil?
            point = intersection(arc_node, arc_node.next, l*2)
            arc_node.segment1.end_point = point
            arc_node.segment1.finish
        end
    end

end

# start at 13:58

