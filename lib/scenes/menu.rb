require "gosu"

class Menu
  MENUCOLOR = Gosu::Color.rgba(10, 10, 10, 225)

  def initialize(state_manager)
    @state_manager  = state_manager
    @font           = Gosu::Font.new(30)
    @menu_options   = ["Play", "Select Level", "Exit"]
    @menu_opt_index = 0
    @levels         = [1, 2, 3, 4]
  end

  def update; end

  def draw
    Gosu.draw_rect(200, 150, 400, 350, MENUCOLOR)
    @font.draw_text("The Last Bounce", 230, 180, 0, 1.75, 1.75)
    @menu_options.each_with_index do |option, index|
      shift = index * 50
      color = index == @menu_opt_index ? Gosu::Color.argb(0xff_ff00ff) : Gosu::Color::WHITE
      @font.draw_text(option, 275, 275 + shift, 1, 1, 1, color)
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      exit
    when Gosu::KB_UP
      @menu_opt_index = (@menu_opt_index - 1) % @menu_options.size
    when Gosu::KB_DOWN
      @menu_opt_index = (@menu_opt_index + 1) % @menu_options.size
    when Gosu::KB_RETURN
      handle_menu_optino_selection
    end
  end

  def handle_menu_optino_selection
    case @menu_options[@menu_opt_index]
    when "Play"
      @state_manager.switch_to(GameWindow.new(@state_manager))
    when "Select Level"

    when "Exit"
      exit
    end
  end
end
