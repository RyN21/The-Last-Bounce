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
    @bounce_vel      = 13
    @vel_decrem      = 1
    @on_solid_object = false
    @ball            = Gosu::Image.new("assets/images/ball.png")
    @state           = :free_fall
    @travel          = :none
  end

  def draw
    @ball.draw(x, y, 0, @ball_scale, @ball_scale)
  end

  def gravity(x, y)
    case @travel
    when :left
      travel_left
    when :right
      travel_right
    end
    @bounce_vel = 13
    @gravity_vel += 0.1
    @y += @gravity_vel
    @state = :bouncing if hits_paddle?
  end

  def bounce
    case @travel
    when :left
      travel_left
    when :right
      travel_right
    end
    @gravity_vel = 0.25
    @bounce_vel -= 0.25
    @y -= @bounce_vel
    @state = :free_fall if @bounce_vel == 0
  end

  def travel_right
    @x += 2
  end

  def travel_left
    @x -= 2
  end

  def hits_paddle?
    @travel = :left if @y + @height >= @paddle.y && @x + @width / 2 >= @paddle.x - @width  && @x + @width / 2 <= @paddle.x + 43
    @travel = :right if @y + @height >= @paddle.y && @x + @width / 2 >= @paddle.x + 86 - @width  && @x + @width / 2 <= @paddle.x + @paddle.width + @width
    @travel = :none if @y + @height >= @paddle.y && @x + @width / 2 >= @paddle.x + 43  && @x + @width / 2 <= @paddle.x + 86

    @y + @height >= @paddle.y && @x > @paddle.x - @width  && @x + @width < @paddle.x + @paddle.width + @width
    # @travel = :none if @y + @height >= @paddle.y && @x > @paddle.x - @width  && @x + @width < @paddle.x + @paddle.width + @width
  end

  def free_fall?
    @state == :free_fall
  end

  def bouncing?
    @state == :bouncing
  end
end
