class Paddle
  WIDTH  = 516
  HEIGHT = 60
  PADDLE_SCALE = 0.25
  SCALED_WIDTH = WIDTH * PADDLE_SCALE
  SCALED_HEIGHT = HEIGHT * 0.25
  WIDTH_THIRD = SCALED_WIDTH / 3
  PADDLE_SPEED = 7

  attr_reader :x, :y, :width, :height, :width_third

  def initialize(x, y, map)
    @x            = x
    @y            = y
    @map          = map
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
    @paddle.draw(x, y, 0, PADDLE_SCALE, PADDLE_SCALE)
  end

  def move_left
    @x -= @x_vel_left unless @map.hits_tile?(@x + 5, @y)
  end

  def move_right
    @x += @x_vel_right unless @map.hits_tile?(@x + @width + 5, @y)
  end
end
