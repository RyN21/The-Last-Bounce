class Ball
  WIDTH  = 35
  HEIGHT = 35
  RADIUS = 35 / 2
  attr_reader :x, :y, :state, :lives
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
    @ball               = Gosu::Image.new("assets/images/dark_purple_ball.png")
    @bounce_sound       = Gosu::Sample.new("assets/sounds/bounce.mp3")
    @collect_gems_sound = Gosu::Sample.new("assets/sounds/collect_coin.mp3")
    @last_time_hit_tile = Gosu.milliseconds
    @lives           = 1
    @collision       = nil
    @state           = :free_fall
    @travel          = :none
  end

  def update
    handle_state
    handle_collision_with_tile
    travel
  end

  def draw
    @ball.draw(@x, @y, 0, @ball_scale, @ball_scale)
  end

  def lose?
    @lives == 0
  end

  def win?
    @x + @width > @map.width * 50 - 15
  end

  def reset_ball(x)
    @x = x
    @y = 100
    @gravity_vel = 0.25
    @travel = :left
    @travel_vel = -2
    @lives -= 1
  end

  def handle_state
    case @state
    when :free_fall
      enable_gravity
    when :bouncing
      enable_bounce
    when :hits_ceiling
      enable_gravity_off_ceiling
    end
  end

  def perimeter_collision
    num_points = 16
    center_x   = @x + @radius
    center_y   = @y + @radius
    collision  = nil

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

  def handle_collision_with_tile
    @collision = perimeter_collision
    case @collision
    when :top
      @y += 7
      @state = :hits_ceiling
    when :bottom
      @y -= 7
      @state = :bouncing
    when :left
      hits_right_side_of_tile
    when :right
      hits_left_side_of_tile
    end
  end

  def enable_gravity
    case @travel
    when :left
      travel_left
    when :right
      travel_right
    end
    @bounce_vel = 13
    @gravity_vel += 0.075
    @y += @gravity_vel
    @state = :bouncing if hits_paddle?
  end

  def enable_bounce
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

  def enable_gravity_off_ceiling
    case @travel
    when :left
      travel_left
    when :right
      travel_left
    end
    @gravity_vel = @bounce_vel * 0.75
    @gravity_vel += 0.1
    @y += @gravity_vel
    @state = :free_fall
  end

  def travel
    @travel = :none if @travel_vel == 0
    @travel = :left if @travel_vel < 0
    @travel = :right if @travel_vel > 0
  end

  def travel_right
    @x += @travel_vel
  end

  def travel_left
    @x += @travel_vel
  end

  def hits_right_side_of_tile
    @travel_vel = -@travel_vel - @bounce_factor * 0.8
    @x -= 5
  end

  def hits_left_side_of_tile
    @travel_vel = -@travel_vel - @bounce_factor * 0.8
    @x += 5
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

  def collect_gems(gems)
    gems.reject! do |gem|
      @collect_gems_sound.play if ((gem.x) - (@x + @radius)).abs < 20 && ((gem.y) - (@y + @radius)).abs < 20
      ((gem.x) - (@x + @radius)).abs < 20 && ((gem.y) - (@y + @radius)).abs < 20
    end
  end
end
