require "gosu"
require_relative "../config/settings"
require_relative "./paddle"
require_relative "./ball"
require_relative "./map"
require_relative "./collectible_gem"

class GameWindow < Gosu::Window
  WIDTH  = Config::WINDOW_WIDTH
  HEIGHT = Config::WINDOW_HEIGHT
  COLOR  = Gosu::Color.rgba(0, 255, 255, 75)
  PADDLE_COLOR  = Gosu::Color.rgba(0, 255, 255, 255)

  def initialize
    super WIDTH, HEIGHT
    self.caption = Config::CAPTION
    Gosu.enable_undocumented_retrofication
    @map    = Map.new("assets/maps/1.txt")
    @paddle = Paddle.new(200, 550, @map)
    @ball   = Ball.new(225, 300, @paddle, @map)
    @camera_x = @camera_y = 0
  end

  def update
    if Gosu.button_down?(Gosu::KB_LEFT)
      @paddle.move_left
    end
    if Gosu.button_down?(Gosu::KB_RIGHT)
      @paddle.move_right
    end
    @ball.update
    @map.update
    @camera_x = [[@paddle.x - WIDTH / 2.5, 0].max, @map.width * 50 - WIDTH].min
    @camera_y = [[@paddle.y - HEIGHT / 2.5, 0].max, @map.height * 50 - HEIGHT].min
    @ball.reset_ball(@paddle.x) if @ball.y > HEIGHT
    @ball.collect_gems(@map.gems)
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
