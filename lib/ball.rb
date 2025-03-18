class Ball
  WIDTH  = 35
  HEIGHT = 35
  RADIUS = 35 / 2
  attr_reader :x, :y, :state
  def initialize(x, y, paddle, map)
    @paddle          = paddle
    @map             = map
    @x               = x
    @y               = y
    @ball_scale      = 1
    @width           = WIDTH * @ball_scale
    @height          = HEIGHT * @ball_scale
    @radius          = RADIUS * @ball_scale
    @gravity_vel     = 0.25
    @bounce_vel      = 13
    @bounce_factor   = 0.2
    @travel_vel      = 0
    @on_solid_object = false
    @ball               = Gosu::Image.new("assets/images/dark_purple_ball.png")
    @bounce_sound       = Gosu::Sample.new("assets/sounds/bounce.mp3")
    @collect_gems_sound = Gosu::Sample.new("assets/sounds/collect_coin.mp3")
    @last_time_hit_tile = Gosu.milliseconds

    @state           = :free_fall
    @travel          = :none
  end

  def update
    case @state
    when :free_fall
      travel_down
    when :bouncing
      travel_up
    when :hits_ceiling
      trave_down_off_ceiling
    end
    hits_wall
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

  def check_perimeter_collision
    num_points = 12
    center_x = @x + @radius
    center_y = @y + @radius
    collision = nil

    num_points.times do |i|
      angle = 2 * Math::PI * i / num_points
      check_x = center_x + Math.cos(angle) * @radius
      check_y = center_y + Math.sin(angle) * @radius

      if @map.hits_tile?(check_x, check_y)
        collision ||= case angle
        when 0.25*Math::PI...0.75*Math::PI then :bottom
        when 0.75*Math::PI...1.25*Math::PI then :right
        when 1.25*Math::PI...1.75*Math::PI then :top
        else :left
        end
      end
    end
    collision
  end

  def travel
    @travel = :none if @travel_vel == 0
    @travel = :left if @travel_vel < 0
    @travel = :right if @travel_vel > 0
  end

  def travel_down
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

  def travel_up
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

  def trave_down_off_ceiling
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
      @travel_vel = -@travel_vel - @bounce_factor
    end
    if hits_right_wall?
      @travel_vel = -@travel_vel - @bounce_factor
    end
  end

  def hits_paddle?
    if @y + @height >= @paddle.y &&
      @y + @height <= @paddle.y + @paddle.height &&
      @x + @width > @paddle.x &&
      @x < @paddle.x + @paddle.width

      paddle_center = @paddle.x + @paddle.width / 2
      ball_center = @x + @radius
      hit_position = (ball_center - paddle_center) / (@paddle.width / 2.0)

      @travel_vel = hit_position * 5
      @travel_vel = @travel_vel.clamp(-5, 5)

      @bounce_sound.play

      true
    else
      false
    end
  end

  def lands_on_tile?
    x = @x + @radius
    y = @y + @height
    @map.hits_tile?(x, y)
  end

  def hits_ceiling?
    x = @x + @radius
    y = @y
    @map.hits_tile?(x, y)
  end

  def hits_left_wall?
    x = @x
    y = @y + @radius
    @map.hits_tile?(x, y)
  end

  def hits_right_wall?
    x = @x + @width
    y = @y + @radius
    @map.hits_tile?(x, y)
  end

  def collect_gems(gems)
    gems.reject! do |gem|
      @collect_gems_sound.play if ((gem.x) - (@x + @radius)).abs < 20 && ((gem.y) - (@y + @radius)).abs < 20
      ((gem.x) - (@x + @radius)).abs < 20 && ((gem.y) - (@y + @radius)).abs < 20
    end
  end
end
