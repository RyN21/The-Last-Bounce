class Ball
  WIDTH  = 70
  HEIGHT = 70
  attr_reader :x, :y, :state
  def initialize(x, y, paddle)
    @paddle          = paddle
    @x               = x
    @y               = y
    @ball_scale      = 0.50
    @width           = WIDTH * @ball_scale
    @height          = HEIGHT * @ball_scale
    @gravity_vel     = 0.25
    @bounce_vel      = 15
    @vel_decrem      = 1
    @on_solid_object = false
    @ball            = Gosu::Image.new("assets/images/ball.png")
    @state           = :free_fall
  end

  def draw
    @ball.draw(x, y, 0, @ball_scale, @ball_scale)
  end

  def gravity(x, y)
    @bounce_vel = 15
    @gravity_vel += 0.1
    @y += @gravity_vel
    @state = :bouncing if hits_paddle?
  end

  def bounce
    @gravity_vel = 0.25
    @bounce_vel -= 0.25
    @y -= @bounce_vel
    @state = :free_fall if @bounce_vel == 0
  end

  def hits_paddle?
    @y + @height >= @paddle.y && @x > @paddle.x - @width  && @x + @width < @paddle.x + @paddle.width + @width
  end

  def free_fall?
    @state == :free_fall
  end

  def bouncing?
    @state == :bouncing
  end
end

#
# psuedo code
#
# downward movement continuously increses and y increases until collides with an object
#
# once it collides with an object, it bounces
