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
    @ball               = Gosu::Image.new("assets/images/dark_purple_ball.png")
    @bounce_sound       = Gosu::Sample.new("assets/sounds/bounce.mp3")
    @collect_gems_sound = Gosu::Sample.new("assets/sounds/collect_coin.mp3")
    @last_time_hit_tile = Gosu.milliseconds

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

  def reset_ball(x)
    @x = x
    @y = 100
    @gravity_vel = 0.25
    @travel = :left
    @travel_vel = -2
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
    # return if Gosu.milliseconds - @last_time_hit_tile < 10
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

    # @last_time_hit_tile = Gosu.milliseconds if @collision
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









# class Ball
#   WIDTH  = 35
#   HEIGHT = 35
#   RADIUS = 35 / 2
#   attr_reader :x, :y, :state
#   def initialize(x, y, paddle, map)
#     @paddle          = paddle
#     @map             = map
#     @x               = x
#     @y               = y
#     @ball_scale      = 1
#     @width           = WIDTH * @ball_scale
#     @height          = HEIGHT * @ball_scale
#     @radius          = RADIUS * @ball_scale
#     @gravity_vel     = 0.25
#     @bounce_vel      = 13
#     @bounce_factor   = 0.2
#     @travel_vel      = 0
#     @on_solid_object = false
#     @ball               = Gosu::Image.new("assets/images/dark_purple_ball.png")
#     @bounce_sound       = Gosu::Sample.new("assets/sounds/bounce.mp3")
#     @collect_gems_sound = Gosu::Sample.new("assets/sounds/collect_coin.mp3")
#     @last_time_hit_tile = Gosu.milliseconds
#
#     @collision       = nil
#     @state           = :free_fall
#     @travel          = :none
#   end
#
#   def update
#     handle_state
#     handle_collision_with_tile
#     travel
#   end
#
#   def draw
#     @ball.draw(@x, @y, 0, @ball_scale, @ball_scale)
#   end
#
#   def reset_ball(x)
#     @x = x
#     @y = 100
#     @gravity_vel = 0.25
#     @travel = :left
#     @travel_vel = -2
#   end
#
#   def handle_state
#     case @state
#     when :free_fall
#       enable_gravity
#     when :bouncing
#       enable_bounce
#     when :hits_ceiling
#       enable_gravity_off_ceiling
#     end
#   end
#
#   def handle_collision_with_tile
#     return if Gosu.milliseconds - @last_time_hit_tile < 100
#
#     @collision = perimeter_collision
#     case @collision
#     when :top
#       @gravity_vel = @bounce_vel.abs * -0.8 # Reverse and reduce vertical velocity
#       @y += 5 # Push down below tile
#       @state = :hits_ceiling
#     when :bottom
#       @gravity_vel = @bounce_vel.abs * 0.8 # Reverse and reduce vertical velocity
#       @y -= 5 # Push up above tile
#       @state = :bouncing
#     when :left
#       @travel_vel = @travel_vel.abs * 0.8 # Reduce horizontal velocity
#       @x += 5 # Push right
#     when :right
#       @travel_vel = -@travel_vel.abs * 0.8 # Reduce horizontal velocity
#       @x -= 5 # Push left
#     end
#
#     @last_time_hit_tile = Gosu.milliseconds if @collision
#     @bounce_sound.play if @collision
#   end
#
#   def perimeter_collision
#     num_points = 16
#     center_x   = @x + @radius
#     center_y   = @y + @radius
#     collision  = nil
#
#     num_points.times do |i|
#       angle = 2 * Math::PI * i / num_points
#       check_x = center_x + Math.cos(angle) * @radius
#       check_y = center_y + Math.sin(angle) * @radius
#
#       if @map.hits_tile?(check_x, check_y)
#         # Calculate direction from ball center to collision point
#         tile_x = (check_x / 50).floor
#         tile_y = (check_y / 50).floor
#         tile_center_x = tile_x * 50 + 25
#         tile_center_y = tile_y * 50 + 25
#
#         dx = center_x - tile_center_x
#         dy = center_y - tile_center_y
#
#         # Determine dominant axis
#         return dx.abs > dy.abs ? (dx < 0 ? :right : :left) : (dy < 0 ? :bottom : :top)
#       end
#     end
#     nil
#   end
#
#   def travel
#     @travel = :none if @travel_vel == 0
#     @travel = :left if @travel_vel < 0
#     @travel = :right if @travel_vel > 0
#   end
#
#   def travel_right
#     @x += @travel_vel
#   end
#
#   def travel_left
#     @x += @travel_vel
#   end
#
#   def enable_gravity
#     case @travel
#     when :left
#       travel_left
#     when :right
#       travel_right
#     end
#     @bounce_vel = 13
#     @gravity_vel += 0.1
#     @y += @gravity_vel
#     @state = :bouncing if hits_paddle?
#   end
#
#   def enable_bounce
#     case @travel
#     when :left
#       travel_left
#     when :right
#       travel_right
#     end
#     @gravity_vel = 0.25
#     @bounce_vel -= 0.25
#     @y -= @bounce_vel
#     @state = :free_fall if @bounce_vel == 0
#   end
#
#   def enable_gravity_off_ceiling
#     case @travel
#     when :left
#       travel_left
#     when :right
#       travel_left
#     end
#     @gravity_vel = @bounce_vel
#     @gravity_vel += 0.1
#     @y += @gravity_vel
#     @state = :free_fall
#   end
#
#   def hits_right_side_of_tile
#     @travel_vel = -@travel_vel - @bounce_factor
#     @x -= 2
#   end
#
#   def hits_left_side_of_tile
#     @travel_vel = -@travel_vel - @bounce_factor
#     @x += 2
#   end
#
#   def hits_paddle?
#     if @y + @height >= @paddle.y &&
#       @y + @height <= @paddle.y + @paddle.height &&
#       @x + @width > @paddle.x &&
#       @x < @paddle.x + @paddle.width
#
#       paddle_center = @paddle.x + @paddle.width / 2
#       ball_center = @x + @radius
#       hit_position = (ball_center - paddle_center) / (@paddle.width / 2.0)
#
#       @travel_vel = hit_position * 5
#       @travel_vel = @travel_vel.clamp(-5, 5)
#
#       @bounce_sound.play
#       true
#     else
#       false
#     end
#   end
#
#   def collect_gems(gems)
#     gems.reject! do |gem|
#       @collect_gems_sound.play if ((gem.x) - (@x + @radius)).abs < 20 && ((gem.y) - (@y + @radius)).abs < 20
#       ((gem.x) - (@x + @radius)).abs < 20 && ((gem.y) - (@y + @radius)).abs < 20
#     end
#   end
# end
