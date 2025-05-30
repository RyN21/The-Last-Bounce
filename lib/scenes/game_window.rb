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

  def initialize(state_manager, level)
    @state_manager   = state_manager
    @level           = level
    @map             = Map.new("assets/maps/level_#{@level}.txt")
    @m1              = Gosu::Image.new("assets/images/mountains_1.png")
    @m2              = Gosu::Image.new("assets/images/mountains_2.png")
    @m3              = Gosu::Image.new("assets/images/mountains_3.png")
    @font            = Gosu::Font.new(30)
    @paddle          = Paddle.new(200, 550, @map)
    @ball            = Ball.new(225, 300, @paddle, @map)
    @paused          = false
    @paused_menu     = false
    @menu_options    = ["Continue", "Restart", "Select Level", "Quit"]
    @lose_options    = ["Try Again", "Select Level", "Quit"]
    @win_options     = ["Next Level", "Select Level", "Quit"]
    # @unlocked_levels = [1]
    # @locked_levels   = [2, 3, 4]
    @level_options          = [1, 2, 3, 4, "Back"]
    @level_index     = 0
    @level_screen    = false
    @menu_opt_index  = 0
    @lose_opt_index  = 0
    @win_opt_index   = 0
    @level_opt_index = 0
    @camera_x = @camera_y = 0
  end

  def update
    return if @paused
    return if @ball.lose?
    return if @ball.win?

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
    @font.draw_text("Lives: #{@ball.lives}", 25, 10, 0, 0.75, 0.75)
    @font.draw_text("The Last Bounce", 325, 10, 0, 0.75, 0.75)
    @font.draw_text("Level: #{@level}", 700, 10, 0, 0.75, 0.75)
    Gosu.translate(-@camera_x, -@camera_y) do
      @paddle.draw
      @ball.draw
    end
    if @paused && !@level_screen
      Gosu.draw_rect(200, 150, 400, 350, MENUCOLOR)
      @font.draw_text("Game Paused", 230, 180, 0, 2, 2)
      @menu_options.each_with_index do |option, index|
        shift = index * 50
        color = index == @menu_opt_index ? Gosu::Color.argb(0xff_ff00ff) : Gosu::Color::WHITE
        @font.draw_text(option, 275, 275 + shift, 1, 1, 1, color)
      end
    end
    if @ball.lose? && !@level_screen
      Gosu.draw_rect(200, 150, 400, 350, MENUCOLOR)
      @font.draw_text("You Lose", 230, 180, 0, 2, 2)
      @lose_options.each_with_index do |option, index|
        shift = index * 50
        color = index == @lose_opt_index ? Gosu::Color.argb(0xff_ff00ff) : Gosu::Color::WHITE
        @font.draw_text(option, 275, 275 + shift, 1, 1, 1, color)
      end
    end
    if @ball.win? && !@level_screen
      Gosu.draw_rect(200, 150, 400, 350, MENUCOLOR)
      @font.draw_text("Level Passed", 230, 180, 0, 2, 2)
      @win_options.each_with_index do |option, index|
        shift = index * 50
        color = index == @win_opt_index ? Gosu::Color.argb(0xff_ff00ff) : Gosu::Color::WHITE
        @font.draw_text(option, 275, 275 + shift, 1, 1, 1, color)
      end
    end
    if @level_screen
      Gosu.draw_rect(200, 150, 400, 350, MENUCOLOR)
      @font.draw_text("Select Level", 230, 180, 0, 2, 2)
      @level_options.each_with_index do |level, index|
        shift = index * 50
        color = index == @level_index ? Gosu::Color.argb(0xff_ff00ff) : Gosu::Color::WHITE
        @font.draw_text(level, 275, 250 + shift, 1, 1, 1, color)
      end
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_SPACE
      @paused = !@paused unless @level_screen || @ball.lose? || @ball.win?
    end

    if @level_screen
      case id
      when Gosu::KB_UP
        cycle_up("level")
      when Gosu::KB_DOWN
        cycle_down("level")
      when Gosu::KB_RETURN
        handle_level_screen_options
      end
    elsif @paused
      case id
      when Gosu::KB_UP
        cycle_up("menu") if !@level_screen
        cycle_up("level") if @level_screen
      when Gosu::KB_DOWN
        cycle_down("menu") if !@level_screen
        cycle_down("level") if @level_screen
      when Gosu::KB_RETURN
        case @level_screen
        when false
          handle_menu_option_selection
        when true
          handle_level_screen_options
        end
      end
    elsif @ball.lose?
      case id
      when Gosu::KB_UP
        cycle_up("lose")
      when Gosu::KB_DOWN
        cycle_down("lose")
      when Gosu::KB_RETURN
        handle_lose_option_selection
      end
    elsif @ball.win?
      case id
      when Gosu::KB_UP
        cycle_up("win")
      when Gosu::KB_DOWN
        cycle_down("win")
      when Gosu::KB_RETURN
        handle_win_option_selection
      end
    end
  end

  def handle_menu_option_selection
    case @menu_options[@menu_opt_index]
    when "Continue"
      @paused = false
    when "Restart"
      set_level(@level)
    when "Select Level"
      level_select
    when "Quit"
      quit
    end
  end

  def handle_lose_option_selection
    case @lose_options[@lose_opt_index]
    when "Try Again"
      set_level(@level)
    when "Select Level"
      level_select
    when "Quit"
      quit
    end
  end

  def handle_win_option_selection
    level = @level
    case @win_options[@win_opt_index]
    when "Next Level"
      level += 1
      set_level(level)
    when "Select Level"
      level_select
    when "Quit"
      quit
    end
  end

  def handle_level_screen_options
    case @level_options[@level_index]
    when 1..4
      set_level(@level_options[@level_index])
      @level_screen = false
      @paused = false
    when "Back"
      @level_screen = false
      @menu_opt_index = 0
    end
  end



  private



  def level_select
    @level_screen = true
    @level_index = 0
    @paused = true unless @ball.win? || @ball.lose?
  end

  def quit
    @state_manager.switch_to(Menu.new(@state_manager))
  end

  def set_level(level)
    @state_manager.switch_to(GameWindow.new(@state_manager, level))
  end

  def cycle_up(options)
    case options
    when "menu"
      @menu_opt_index = (@menu_opt_index - 1) % @menu_options.size
    when "win"
      @win_opt_index = (@win_opt_index - 1) % @win_options.size
    when "lose"
      @lose_opt_index = (@lose_opt_index - 1) % @lose_options.size
    when "level"
      @level_index = (@level_index - 1) % @level_options.size
    end
  end

  def cycle_down(options)
    case options
    when "menu"
      @menu_opt_index = (@menu_opt_index + 1) % @menu_options.size
    when "win"
      @win_opt_index = (@win_opt_index + 1) % @win_options.size
    when "lose"
      @lose_opt_index = (@lose_opt_index + 1) % @lose_options.size
    when "level"
      @level_index = (@level_index + 1) % @level_options.size
    end
  end
end





# def draw_rectend
# Gosu.translate(-@camera_x * 0.2, 0) { @m1.draw(-150, 130, 0, 4, 4) }
# Gosu.translate(-@camera_x * 0.5, 0) { @m2.draw(-150, 170, 0, 4, 4) }
# Gosu.translate(-@camera_x * 0.65, 0) { @m3.draw(-150, 375, 0, 4, 4) }
# end
