require "gosu"
require_relative "../config/settings"
require_relative "./paddle"
require_relative "./ball"
require_relative "./map"

class GameWindow < Gosu::Window
  WIDTH  = Config::WINDOW_WIDTH
  HEIGHT = Config::WINDOW_HEIGHT
  COLOR  = Gosu::Color.rgba(0, 255, 255, 75)
  PADDLE_COLOR  = Gosu::Color.rgba(0, 255, 255, 255)

  def initialize
    super WIDTH, HEIGHT
    self.caption = Config::CAPTION
    @map    = Map.new("assets/maps/1.txt")
    @paddle = Paddle.new(200, 550)
    @ball   = Ball.new(225, 100, @paddle, @map)
    @camera_x = @camera_y = 0
  end

  def update
    if Gosu.button_down?(Gosu::KB_LEFT)
      @paddle.move_left
    end
    if Gosu.button_down?(Gosu::KB_RIGHT)
      @paddle.move_right
    end
    case @ball.state
    when :free_fall
      @ball.gravity(@ball.x, @ball.y)
    when :bouncing
      @ball.bounce
    when :hits_ceiling
      @ball.bounce_off_ceiling
    end
    @camera_x = [[@paddle.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
    @camera_y = [[@paddle.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min
  end

  def draw
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, COLOR, z = 0)
    @map.draw(@camera_x, @camera_y, WIDTH, HEIGHT)
    Gosu.translate(-@camera_x, -@camera_y) do
      @paddle.draw
      @ball.draw
    end
  end
end

GameWindow.new.show
