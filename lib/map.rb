TILE_SIZE = 50

class Map
  attr_reader :width, :height
  def initialize(filename)
    @tile_images = {
      [:west]     => Gosu::Image.new("assets/tiles/left.png"),
      [:east]     => Gosu::Image.new("assets/tiles/right.png"),
      [:plain]    => Gosu::Image.new("assets/tiles/plain.png"),
      [:left_tb]  => Gosu::Image.new("assets/tiles/left_tb.png"),
      [:right_tb] => Gosu::Image.new("assets/tiles/right_tb.png"),
      [:tb]       => Gosu::Image.new("assets/tiles/top_bottom.png")
    }
    gem_frames = Gosu::Image.load_tiles("assets/images/green_gem.png", 16, 16, retro: true)
    lines      = File.readlines(filename).map { |line| line.chomp }
    @height    = lines.size
    @width     = lines[0].size
    @gems      = []
    @tiles     = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when "x"
          [:east]
        when "v"
          [:west]
        when "#"
          [:plain]
        when "<"
          [:left_tb]
        when ">"
          [:right_tb]
        when "="
          [:tb]
        when "g"
          @gems.push(CollectibleGem.new(gem_frames, x * 50 + 25, y * 50 + 25))
          nil
        else
          nil
        end
      end
    end
  end

  def update
    @gems.each { |g| g.update}
  end

  def draw(camera_x, camera_y, window_width, window_height)
    start_x = (camera_x / TILE_SIZE).floor
    end_x = (((camera_x + window_width) / TILE_SIZE).ceil).clamp(0, @width - 1)
    start_y = (camera_y / TILE_SIZE).floor
    end_y = (((camera_y + window_height) / TILE_SIZE).ceil).clamp(0, @height - 1)

    (start_y..end_y).each do |y|
      (start_x..end_x).each do |x|
        tile = @tiles[x][y]

        if tile
          @tile_images[tile].draw(
            x * TILE_SIZE - camera_x - 5,
            y * TILE_SIZE - camera_y - 5,
            0
          )
        end
      end
    end

    @gems.each do |gem|
      gem.draw(camera_x, camera_y)
    end
  end

  def hits_tile?(x, y)
    tile_x = (x / TILE_SIZE).floor
    tile_y = (y / TILE_SIZE).floor
    return false if tile_x < 0 || tile_y < 0 || tile_y >= @height
    @tiles[tile_x][tile_y] != nil
  end
end



# image_path  = Config::GRASS_TILES_IMAGES[walls.sort] || "assets/tiles/grass_tiles/plain_grass.png"
# @tile_image = Gosu::Image.new(image_path)
# end
