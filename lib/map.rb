TILE_SIZE = 50

class Map
  attr_reader :width, :height, :gems, :tiles, :breakable_tiles
  def initialize(filename)
    @tile_images = {
      [:top]          => Gosu::Image.new("assets/tiles/top.png"),
      [:bottom]       => Gosu::Image.new("assets/tiles/bottom.png"),
      [:left]         => Gosu::Image.new("assets/tiles/left.png"),
      [:right]        => Gosu::Image.new("assets/tiles/right.png"),
      [:plain]        => Gosu::Image.new("assets/tiles/plain.png"),
      [:all_side]     => Gosu::Image.new("assets/tiles/all_sides.png"),
      [:left_tb]      => Gosu::Image.new("assets/tiles/left_tb.png"),
      [:right_tb]     => Gosu::Image.new("assets/tiles/right_tb.png"),
      [:top_sides]    => Gosu::Image.new("assets/tiles/top_sides.png"),
      [:bottom_sides] => Gosu::Image.new("assets/tiles/bottom_sides.png"),
      [:corner_bl]    => Gosu::Image.new("assets/tiles/corner_bottom_left.png"),
      [:corner_br]    => Gosu::Image.new("assets/tiles/corner_bottom_right.png"),
      [:corner_tl]    => Gosu::Image.new("assets/tiles/corner_top_left.png"),
      [:corner_tr]    => Gosu::Image.new("assets/tiles/corner_top_right.png"),
      [:lr]           => Gosu::Image.new("assets/tiles/left_right.png"),
      [:tb]           => Gosu::Image.new("assets/tiles/top_bottom.png")
      # [:breakable]    => Gosu::Image.new("assets/tiles/breakable_tile_1.png")
    }
    gem_frames       = Gosu::Image.load_tiles("assets/images/green_gem.png", 16, 16, retro: true)
    lines            = File.readlines(filename).map { |line| line.chomp }
    @height          = lines.size
    @width           = lines[0].size
    @gems            = []
    @breakable_tiles = []
    @tiles           = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when "t"
          [:top]
        when "b"
          [:bottom]
        when "r"
          [:right]
        when "l"
          [:left]
        when "p"
          [:plain]
        when "<"
          [:left_tb]
        when ">"
          [:right_tb]
        when "V"
          [:bottom_sides]
        when "A"
          [:top_sides]
        when "="
          [:tb]
        when "H"
          [:lr]
        when "#"
          [:all_side]
        when "F"
          [:corner_tl]
        when "7"
          [:corner_tr]
        when "L"
          [:corner_bl]
        when "4"
          [:corner_br]
        when "B"
          tile = BreakableTile.new(x, y)
          @breakable_tiles << tile
          tile
        when "g"
          @gems.push(CollectibleGem.new(gem_frames, x * 50 + 20, y * 50 + 16))
          nil
        else
          nil
        end
      end
    end
  end

  def update
    @gems.each { |g| g.update}
    @breakable_tiles.each { |t| t.update }
  end

  def draw(camera_x, camera_y, window_width, window_height)
    start_x = (camera_x / TILE_SIZE).floor
    end_x = (((camera_x + window_width) / TILE_SIZE).ceil).clamp(0, @width - 1)
    start_y = (camera_y / TILE_SIZE).floor
    end_y = (((camera_y + window_height) / TILE_SIZE).ceil).clamp(0, @height - 1)

    (start_y..end_y).each do |y|
      (start_x..end_x).each do |x|
        tile = @tiles[x][y]

        if tile && tile.class != BreakableTile
          @tile_images[tile].draw(
            x * TILE_SIZE - camera_x - 5,
            y * TILE_SIZE - camera_y - 5,
            0
          )
        end
        if tile.class == BreakableTile
          if tile.state == :good
            tile.image[0].draw(
              x * TILE_SIZE - camera_x - 5,
              y * TILE_SIZE - camera_y - 5,
              0
            )
          end
          if tile.state == :cracked_1
            tile.image[1].draw(
              x * TILE_SIZE - camera_x - 5,
              y * TILE_SIZE - camera_y - 5,
              0
            )
          end
          if tile.state == :cracked_2
            tile.image[2].draw(
              x * TILE_SIZE - camera_x - 5,
              y * TILE_SIZE - camera_y - 5,
              0
            )
          end
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
    if @tiles[tile_x][tile_y] != nil && @tiles[tile_x][tile_y].class == BreakableTile
      tile = @tiles[tile_x][tile_y]
      hits_breakable_tile(tile)
      @tiles[tile_x][tile_y] = nil if tile.destroyed?
    end
    @tiles[tile_x][tile_y] != nil
  end

  def hits_breakable_tile(tile)
    tile.increase_hit_count
  end
end
