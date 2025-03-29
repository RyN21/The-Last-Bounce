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
      [:tb]           => Gosu::Image.new("assets/tiles/top_bottom.png"),
      [:bars]           => Gosu::Image.new("assets/tiles/bars_wood.png")
    }
    gem_frames           = Gosu::Image.load_tiles("assets/images/green_gem.png", 16, 16, retro: true)
    lines                = File.readlines(filename).map { |line| line.chomp }
    @height              = lines.size
    @width               = lines[0].size
    @hit_sound           = Gosu::Sample.new("assets/sounds/hit.mp3")
    @last_hit_sound_time = Gosu.milliseconds
    @gate_open_sound     = Gosu::Sample.new("assets/sounds/gate_open.mp3")
    @gems                = []
    @breakable_tiles     = []
    @bar_tiles           = []
    @tiles_to_remove = []
    @tiles               = Array.new(@width) do |x|
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
        when "j"
          @bar_tiles << :bars
          [:bars]
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
    open_finish_line if @gems.empty? && !@bar_tiles.empty?
    @tiles_to_remove.each { |x, y| @tiles[x][y] = nil }
    @tiles_to_remove.clear
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
          if tile.health == 3
            tile.image[0].draw(
              x * TILE_SIZE - camera_x - 5,
              y * TILE_SIZE - camera_y - 5,
              0
            )
          end
          if tile.health == 2
            tile.image[1].draw(
              x * TILE_SIZE - camera_x - 5,
              y * TILE_SIZE - camera_y - 5,
              0
            )
          end
          if tile.health == 1
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

    tile = @tiles[tile_x][tile_y]
    return false unless tile

    if tile.is_a?(BreakableTile)
      tile.gets_hit
      @tiles_to_remove << [tile_x, tile_y] if tile.destroyed?
      return true
    else
      @hit_sound.play if Gosu.milliseconds - @last_hit_sound_time > 100
      @last_hit_sound_time = Gosu.milliseconds
      return true
    end

    !tile.is_a?(BreakableTile) || !tile.destroyed?
  end

  def paddle_hits_tile?(x, y)
    tile_x = (x / TILE_SIZE).floor
    tile_y = (y / TILE_SIZE).floor
    return false if tile_x < 0 || tile_y < 0 || tile_y >= @height

    @tiles[tile_x][tile_y] != nil
  end

  def open_finish_line
    @bar_tiles.delete(:bars)
    @gate_open_sound.play
    @width.times do |x|
      @height.times do |y|
        @tiles[x][y] = nil if @tiles[x][y] == [:bars]
      end
    end
  end

  def hits_breakable_tile(tile)
    tile.gets_hit
  end
end
