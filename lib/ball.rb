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
    @travel_vel      = 0.0
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
  end

  def draw
    @ball.draw(@x, @y, 0, @ball_scale, @ball_scale)
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

  def reset_ball(x)
    @x = x
    @y = 300
    @gravity_vel = 0.25
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
      @travel = :right
      @travel_vel = -@travel_vel
    end
    if hits_right_wall?
      @travel = :left
      @travel_vel = -@travel_vel
    end
  end

  def hits_corner
    if hits_corner_tile?
      case @travel
      when :right
        @travel = :left
      when :left
        @travel = :right
      when :none
        @travel = :none
      end
    end
  end

  def hits_paddle?
    if @y + @height >= @paddle.y && @x + @width / 2 >= @paddle.x - @width  && @x + @width / 2 <= @paddle.x + @paddle.width_third
      case @travel  # HITS LeFT SIDE OF PADDLE
      when :left
        @travel_vel -= 1
      when :right
        @travel = :none
        @travel_vel = 0
      when :none
        @travel_vel -= 1
        @travel = :left
      end
    end
    if @y + @height >= @paddle.y && @x + @width / 2 >= @paddle.x + @paddle.width_third * 2 - @width  && @x + @width / 2 <= @paddle.x + @paddle.width + @width
      case @travel  # HITS RIGHT SIDE OF PADDLE
      when :right
        @travel_vel += 1 if @travel_vel < 5
      when :left
        @travel = :none
        @travel_vel = 0
      when :none
        @travel_vel += 1
        @travel = :right
      end
    end
    if @y + @height >= @paddle.y && @x + @width / 2 >= @paddle.x + @paddle.width_third  && @x + @width / 2 <= @paddle.x + @paddle.width_third * 2
      case @travel  # HITS MIDDLE OF PADDLE
      when :none
        @travel_vel = 0
      when :left
        @travel_vel += 1
        @travel = :none if @travel_vel == 0
      when :right
        @travel_vel -= 1
        @travel = :none if @travel_vel == 0

      end
    end

    @y + @height >= @paddle.y && @x > @paddle.x - @width  && @x + @width < @paddle.x + @paddle.width + @width
    # @travel = :none if @y + @height >= @paddle.y && @x > @paddle.x - @width  && @x + @width < @paddle.x + @paddle.width + @width
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
    corners = [[@x, @y],
      [@x, @y + @width],
      [@x + @height, @y],
      [@x + @height, @y + @width]]
    coeners.any? do |coord|
      @map.hits_tile?(coord[0], coord[1])
    end
  end

  def free_fall?
    @state == :free_fall
  end

  def bouncing?
    @state == :bouncing
  end
end


# UPDATE balss travel distance / velocity whenever it hits the paddle
