TILE_SIZE = 50

class Map
  attr_reader :width, :height
  def initialize(filename)
    @tile_images = {
      [:west] => Gosu::Image.new("assets/tiles/left.png"),
      [:east] => Gosu::Image.new("assets/tiles/right.png"),
      [:plain] => Gosu::Image.new("assets/tiles/plain.png"),
      [:left_tb] => Gosu::Image.new("assets/tiles/left_tb.png"),
      [:right_tb] => Gosu::Image.new("assets/tiles/right_tb.png"),
      [:tb] => Gosu::Image.new("assets/tiles/top_bottom.png")
    }
    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width  = lines[0].size
    @tiles  = Array.new(@width) do |x|
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
        else
          nil
        end
      end
    end
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
    # @height.times do |y|
    #   @width.times do |x|
    #     tile = @tiles[x][y]
    #     if tile
    #       @tile_images[tile].draw(x * 50 - 5, y* 50 - 5, 0)
    #     end
    #   end
    # end
  end

  def tile_floor?(x, y)
    tile_x = (x / TILE_SIZE).floor
    tile_y = (y / TILE_SIZE).floor
    return false if tile_x < 0 || tile_y < 0 || tile_y >= @height
    @tiles[tile_x][tile_y] != nil
  end

  def tile_ceiling?(x, y)
    tile_x = (x / TILE_SIZE).floor
    tile_y = (y / TILE_SIZE).floor
    return false if tile_x < 0 || tile_y < 0 || tile_y >= @height
    @tiles[tile_x][tile_y] != nil
  end
end



# image_path  = Config::GRASS_TILES_IMAGES[walls.sort] || "assets/tiles/grass_tiles/plain_grass.png"
# @tile_image = Gosu::Image.new(image_path)
# end
