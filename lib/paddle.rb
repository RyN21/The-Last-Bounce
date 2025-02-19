class Paddle
  WIDTH  = 516
  HEIGHT = 60
  PADDLE_SCALE = 0.25
  SCALED_WIDTH = WIDTH * PADDLE_SCALE
  SCALED_HEIGHT = HEIGHT * 0.25
  WIDTH_THIRD = SCALED_WIDTH / 3
  PADDLE_SPEED = 4

  attr_reader :x, :y, :width, :height, :width_third

  def initialize(x, y)
    @x            = x
    @y            = y
    @width        = SCALED_WIDTH
    @height       = SCALED_HEIGHT
    @width_third  = WIDTH_THIRD
    @x_vel_left   = PADDLE_SPEED
    @x_vel_right  = PADDLE_SPEED
    @paddle       = Gosu::Image.new("assets/images/paddle.png")
  end

  def update

  end

  def draw
    @paddle.draw(x, y, 0, PADDLE_SCALE, 0.25)
  end

  def move_left
    @x -= @x_vel_left
    # if @x < 0
    #   @x_vel_left = 0
    # else
    #   @x_vel_left = PADDLE_SPEED
    # end
  end

  def move_right
    @x += @x_vel_right
    # if @x > 668
    #   @x_vel_right = 0
    # else
    #   @x_vel_right = PADDLE_SPEED
    # end
  end
end
