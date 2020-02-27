require 'ostruct'
require_relative 'voronoi'

class WorldGenerator

    MIN_PLATE_COUNT = 5
    MAX_PLATE_COUNT = 10

    def initialize(options)
        seed = options[:seed]&.hash || Random.new_seed
        @rng = Random.new(seed)

        @planet = OpenStruct.new
        @planet.equatorial_circumference = options[:width]
        @planet.meridional_circumference = options[:height]
        @planet.spin_speed = options[:spin]
        @planet.axial_tilt = options[:tilt]
    end

    def generate
        create_tectonic_plates
        collide_plates
        create_continents
        create_wind_regions
        create_sea_currents
        determine_biomes

        return @planet
    end

    def create_tectonic_plates
        plate_count = MIN_PLATE_COUNT + @rng.rand(MAX_PLATE_COUNT - MIN_PLATE_COUNT)
        central_points = []
        plate_count.times do 
            x = rand(@world_width)
            y = rand(@world_height)
            central_points.push( [x, y] )
        end
        @planet.plates = Voronoi.diagram(@planet.equatorial_circumference, @planet.meridional_circumference, central_points)
    end


    def collide_plates
        plate_movements = @planet.plates.map { @rng.rand(360) }
    end

    def create_continents
        continents = []
        generate_height_map
    end

    def generate_height_map
        height_map = []
    end

    def create_wind_regions
        winds = []
        temperature_map = []
    end

    def create_sea_currents
        currents = []
        humidity_map = []
    end

    def determine_biomes
        biome_map = []
    end


end


OPTIONS = {
    seed: "lome",
    # width: 40_075_000, # metres (earth size)
    # height: 13_832_880, # metres (earth size)
    width: 400, # metres
    height: 138, # metres
    spin: 444.5, # metres / second
    tilt: 23.44, # degrees

    # TODO: These do nothing yet
    temperature: nil,
    water: nil,
}

gen = WorldGenerator.new(OPTIONS)
world = gen.generate
p world