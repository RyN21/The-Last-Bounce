require "gosu"
require_relative "../config/settings"
require_relative "./paddle"

class GameWindow < Gosu::Window
  WIDTH  = Config::WINDOW_WIDTH
  HEIGHT = Config::WINDOW_HEIGHT
  COLOR  = Gosu::Color.rgba(0, 255, 255, 75)
  PADDLE_COLOR  = Gosu::Color.rgba(0, 255, 255, 255)

  def initialize
    super WIDTH, HEIGHT
    self.caption = Config::CAPTION

    @player = Paddle.new(200, 550)
    @ball   = Ball.new(225, 500)
  end

  def update
    if Gosu.button_down?(Gosu::KB_LEFT)
      @player.move_left
    end
    if Gosu.button_down?(Gosu::KB_RIGHT)
      @player.move_right
    end
    # @ball.
  end

  def draw
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, COLOR, z = 0)
    @player.draw
    @ball.draw
  end
end

GameWindow.new.show
