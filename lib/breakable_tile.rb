class BreakableTile
  attr_reader :hit_count, :image, :state
  def initialize(x, y)
    @x = x
    @y = y
    @hit_count = 0
    @frame     = 0
    @image     = Gosu::Image.load_tiles("assets/tiles/breakable_bricks.png", 50, 50, retro: true)
    @state     = :good
  end

  def update
    state_update
  end

  def state_update
    @state = :good if @hit_count == 0
    @state = :cracked_1 if @hit_count == 1
    @state = :cracked_2 if @hit_count == 2
    @state = :destroyed if @hit_count == 3
  end

  def destroyed?
    @state == :destroyed
  end

  def increase_hit_count
    @hit_count += 1
  end
end
