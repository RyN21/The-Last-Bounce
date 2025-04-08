require "gosu"
require "./config/settings"
require_relative "../entities/paddle"
require_relative "../entities/ball"
require_relative "../map"
require_relative "../entities/collectible_gem"
require_relative "../entities/breakable_tile"

class GameWindow
  WIDTH  = Config::WINDOW_WIDTH
  HEIGHT = Config::WINDOW_HEIGHT
  COLOR  = Gosu::Color.rgba(120, 100, 255, 255)
  MENUCOLOR = Gosu::Color.rgba(10, 10, 10, 225)

  def initialize(state_manager)
    @state_manager  = state_manager
    @map            = Map.new("assets/maps/1.txt")
    @m1             = Gosu::Image.new("assets/images/mountains_1.png")
    @m2             = Gosu::Image.new("assets/images/mountains_2.png")
    @m3             = Gosu::Image.new("assets/images/mountains_3.png")
    @font           = Gosu::Font.new(30)
    @paddle         = Paddle.new(200, 550, @map)
    @ball           = Ball.new(225, 300, @paddle, @map)
    @paused         = false
    @pause_pressed  = false
    @paused_menu    = false
    @menu_options   = ["Continue", "Restart", "Quit"]
    @menu_opt_index = 0
    @camera_x = @camera_y = 0
  end

  def update
    if Gosu.button_down?(Gosu::KB_P) && !@pause_pressed
      @paused = !@paused
      @paused_menu   = @paused
      @pause_pressed = true
    end
    @pause_pressed = false unless Gosu.button_down?(Gosu::KB_P)
    return if @paused

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
    @map.draw(@camera_x, @camera_y, WIDTH, HEIGHT)
    Gosu.translate(-@camera_x, -@camera_y) do
      @paddle.draw
      @ball.draw
    end
    if @paused
      Gosu.draw_rect(200, 150, 400, 350, MENUCOLOR)
      @font.draw_text("Game Paused", 230, 180, 0, 2, 2)
      @menu_options.each_with_index do |option, index|
        shift = index * 50
        color = index == @menu_opt_index ? Gosu::Color.argb(0xff_ff00ff) : Gosu::Color::WHITE
        @font.draw_text(option, 275, 275 + shift, 1, 1, 1, color)
      end
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      @state_manager.switch_to(Menu.new(@state_manager))
    end
    if @paused
      case id
      when Gosu::KB_UP
        @menu_opt_index = (@menu_opt_index - 1) % @menu_options.size
      when Gosu::KB_DOWN
        @menu_opt_index = (@menu_opt_index + 1) % @menu_options.size
      when Gosu::KB_RETURN
        handle_menu_optino_selection
      end
    end
  end

  def handle_menu_optino_selection
    case @menu_opt_index
    when 0
      @paused = false
    when 1
      @paused = false
    when 2
      @paused = false
    end
  end
end





# def draw_rectend
# Gosu.translate(-@camera_x * 0.2, 0) { @m1.draw(-150, 130, 0, 4, 4) }
# Gosu.translate(-@camera_x * 0.5, 0) { @m2.draw(-150, 170, 0, 4, 4) }
# Gosu.translate(-@camera_x * 0.65, 0) { @m3.draw(-150, 375, 0, 4, 4) }
# end
