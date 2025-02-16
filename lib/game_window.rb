require "gosu"
require_relative "../config/settings"
require_relative "./paddle"
require_relative "./ball"

class GameWindow < Gosu::Window
  WIDTH  = Config::WINDOW_WIDTH
  HEIGHT = Config::WINDOW_HEIGHT
  COLOR  = Gosu::Color.rgba(0, 255, 255, 75)
  PADDLE_COLOR  = Gosu::Color.rgba(0, 255, 255, 255)

  def initialize
    super WIDTH, HEIGHT
    self.caption = Config::CAPTION

    @paddle = Paddle.new(200, 550)
    @ball   = Ball.new(225, 100, @paddle)
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
    end
  end

  def draw
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, COLOR, z = 0)
    @paddle.draw
    @ball.draw
  end
end

GameWindow.new.show
