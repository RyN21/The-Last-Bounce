class Paddle
  attr_reader :x, :y, :width, :height
  WIDTH  = 516
  HEIGHT = 60
  def initialize(x, y)
    @x            = x
    @y            = y
    @paddle_scale = 0.25
    @width        = WIDTH * @paddle_scale
    @height        = HEIGHT * @paddle_scale
    @paddle_speed = 4
    @x_vel_left   = @paddle_speed
    @x_vel_right  = @paddle_speed
    @paddle       = Gosu::Image.new("assets/images/paddle.png")
  end

  def update

  end

  def draw
    @paddle.draw(x, y, 0, @paddle_scale, @paddle_scale)
  end

  def move_left
    @x -= @x_vel_left
    if @x < 0
      @x_vel_left = 0
    else
      @x_vel_left = @paddle_speed
    end
  end

  def move_right
    @x += @x_vel_right
    if @x > 668
      @x_vel_right = 0
    else
      @x_vel_right = @paddle_speed
    end
  end
end
