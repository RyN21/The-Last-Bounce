require "gosu"
require_relative "../config/settings"
require_relative "./paddle"
require_relative "./ball"
require_relative "./map"
require_relative "./collectible_gem"
require_relative "./breakable_tile"

class GameWindow
  def initialize(state_manager)
    @state_manager = state_manager
    @map    = Map.new("assets/maps/1.txt")
    @m1     = Gosu::Image.new("assets/images/mountains_1.png")
    @m2     = Gosu::Image.new("assets/images/mountains_2.png")
    @m3     = Gosu::Image.new("assets/images/mountains_3.png")
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
    @ball.reset_ball(@paddle.x + @paddle.width / 2) if @ball.y > HEIGHT
    @ball.collect_gems(@map.gems)
  end

  def draw
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, COLOR, z = 0)
    # Gosu.translate(-@camera_x * 0.2, 0) { @m1.draw(-150, 130, 0, 4, 4) }
    # Gosu.translate(-@camera_x * 0.5, 0) { @m2.draw(-150, 170, 0, 4, 4) }
    # Gosu.translate(-@camera_x * 0.65, 0) { @m3.draw(-150, 375, 0, 4, 4) }
    @map.draw(@camera_x, @camera_y, WIDTH, HEIGHT)
    Gosu.translate(-@camera_x, -@camera_y) do
      @paddle.draw
      @ball.draw
    end
  end

  def button_down(id)

  end
end

GameWindow.new.show
