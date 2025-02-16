class Ball
  attr_reader :x, :y
  def initialize(x, y)
    @x               = x
    @y               = y
    @gravity_vel     = 0.5
    @bounce_vel      = 15
    @vel_decrem      = 1
    @on_solid_object = false
    @ball            = Gosu::Image.new("assets/images/ball.png")
  end

  def draw
    @ball.draw(x, y, 0, 0.50, 0.50)
  end

  def gravity
    @gravity_vel += 0.1
    @y += @gravity_vel
    if on_solid_object?
      @bounce_vel = 15
      @gravity_vel = 1
    end
  end

  def bounce
    @bounce_vel -= 1
    @y -= @bounce_vel
  end

  def on_solid_object?
    @on_solid_object
  end
end
