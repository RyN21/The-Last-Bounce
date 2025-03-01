class BreakableTile
  attr_reader :hit_count, :image, :state
  def initialize(x, y)
    @x = x
    @y = y
    @hit_count = 0
    @frame     = 0
    @image     = Gosu::Image.load_tiles("assets/tiles/breakable_bricks.png", 50, 50, retro: true)
    # @image_crk = Gosu::Image.new("assets/tiles/breakable_tile_2.png")
    @state     = :good
  end

  def update
    state_update
  end

  def state_update
    @state = :good if @hit_count == 0
    @state = :cracked if @hit_count == 1
    @state = :destroyed if @hit_count == 2
  end

  def destroyed?
    @state == :destroyed
  end

  def increase_hit_count
    @hit_count += 1
  end

  # def draw(camera_x, camera_y)
  #   screen_x = @x - camera_x
  #   screen_y = @y - camera_y
  #   @tile.draw(screen_x, screen_y, 0, 0, 1, 1)
  # end
end
