class Ball
  WIDTH  = 70
  HEIGHT = 70
  RADIUS = 35
  attr_reader :x, :y, :state
  def initialize(x, y, paddle, map)
    @paddle          = paddle
    @map             = map
    @x               = x
    @y               = y
    @ball_scale      = 0.50
    @width           = WIDTH * @ball_scale
    @height          = HEIGHT * @ball_scale
    @radius          = RADIUS * @ball_scale
    @gravity_vel     = 0.25
    @bounce_vel      = 13
    @travel_vel      = 0
    @on_solid_object = false
    @ball            = Gosu::Image.new("assets/images/ball.png")
    @state           = :free_fall
    @travel          = :none
  end

  def update
    case @state
    when :free_fall
      gravity(@x, @y)
    when :bouncing
      bounce
    when :hits_ceiling
      bounce_off_ceiling
    end
    hits_wall
    hits_corner
    travel
  end

  def draw
    @ball.draw(@x, @y, 0, @ball_scale, @ball_scale)
  end

  def reset_ball(x)
    @x = x
    @y = 100
    @gravity_vel = 0.25
    @travel = :left
    @travel_vel = -2
  end

  def travel
    @travel = :none if @travel_vel == 0
    @travel = :left if @travel_vel < 0
    @travel = :right if @travel_vel > 0
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
    @state = :bouncing if hits_paddle? || lands_on_tile?
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
    @state = :hits_ceiling if hits_ceiling?
  end

  def bounce_off_ceiling
    case @travel
    when :left
      travel_left
    when :right
      travel_left
    end
    @gravity_vel = @bounce_vel
    @gravity_vel += 0.1
    @y += @gravity_vel
    @state = :free_fall
  end

  def travel_right
    @x += @travel_vel
  end

  def travel_left
    @x += @travel_vel
  end

  def hits_wall
    if hits_left_wall?
      @travel_vel = -@travel_vel
    end
    if hits_right_wall?
      @travel_vel = -@travel_vel
    end
  end

  def hits_corner
    if hits_corner_tile?
      case @state
      when :free_fall
        hits_wall
      when :bouncing
        hits_wall
      end
    end
  end

  def hits_paddle?
    if @y + @height >= @paddle.y && @x + @width > @paddle.x && @x < @paddle.x + @paddle.width
      paddle_center = @paddle.x + @paddle.width / 2
      ball_center = @x + @radius
      hit_position = (ball_center - paddle_center) / (@paddle.width / 2.0)

      @travel_vel = hit_position * 5  # Adjust this multiplier to change the maximum horizontal velocity
      @travel_vel = @travel_vel.clamp(-4, 4)  # Limit the horizontal velocity

      true
    else
      false
    end
  end

  def lands_on_tile?
    x = @x + @width / 2
    y = @y + @height
    @map.hits_tile?(x, y)
  end

  def hits_ceiling?
    x = @x + @width / 2
    y = @y
    @map.hits_tile?(x, y)
  end

  def hits_left_wall?
    x = @x
    y = @y + @height / 2
    @map.hits_tile?(x, y)
  end

  def hits_right_wall?
    x = @x + @width
    y = @y + @height / 2
    @map.hits_tile?(x, y)
  end

  def hits_corner_tile?
    x = @x + @radius
    y = @y + @radius
    @map.corner_hits_tile?(x, y)
    # corners = [[@x + 5, @y + 5],
    #   [@x + 5, @y - 5 + @width],
    #   [@x - 5 + @height, @y + 5],
    #   [@x - 5 + @height, @y - 5 + @width]]
    # corners.any? do |coord|
    #   @map.corner_hits_tile?(coord[0], coord[1])
    # end
  end

  def collect_gems(gems)
    gems.reject! do |gem|
      ((gem.x + 16) - (@x + @radius)).abs < 15 && ((gem.y + 16) - (@y + @radius)).abs < 40
    end
  end
end


# UPDATE balss travel distance / velocity whenever it hits the paddle
