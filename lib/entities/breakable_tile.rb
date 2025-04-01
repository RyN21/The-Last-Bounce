class BreakableTile
  attr_reader :image, :health
  attr_accessor :last_hit_time
  def initialize(x, y)
    @x = x
    @y = y
    @frame           = 0
    @image           = Gosu::Image.load_tiles("assets/tiles/breakable_bricks.png", 50, 50, retro: true)
    @hit_brick_sound = Gosu::Sample.new("assets/sounds/cracked.mp3")
    @health          = 3
    @last_time_hit   = Gosu.milliseconds
  end

  def update; end

  def destroyed?
    @health <= 0
  end

  def gets_hit
    return if destroyed?

    current_time = Gosu.milliseconds
    if current_time - @last_time_hit > 500
      @hit_brick_sound.play
      @health -= 1
      @last_time_hit = current_time
    end
  end
end
