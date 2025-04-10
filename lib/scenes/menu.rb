require "gosu"

class Menu
  def initialize(state_manager)
    @state_manager = state_manager
    @font = Gosu::Font.new(30)
  end

  def update; end

  def draw
    @font.draw_text("Press ENTER to play", 250, 250, 0, 1, 1)
    @levels = [1, 2, 3, 4]
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      exit
    when Gosu::KB_RETURN
      @state_manager.switch_to(GameWindow.new(@state_manager))
    end
  end
end
