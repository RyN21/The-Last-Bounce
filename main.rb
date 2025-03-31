require "gosu"
require_relative "lib/state_manager"
require_relative "lib/game_window"
require_relative "lib/menu"

class Main < Gosu::Window
  WIDTH   = Config::WINDOW_WIDTH
  HEIGHT  = Config::WINDOW_HEIGHT
  CAPTION = Config::CAPTION
  COLOR   = Gosu::Color.rgba(120, 100, 255, 255)

  def initialize
    super WIDTH, HEIGHT
    self.caption = CAPTION
    Gosu.enable_undocumented_retrofication
    @state_manager = StateManager.new(self)
    @state_manager.switch_to(Menu.new(@state_manager))
  end

  def update
    @state_manager.update
  end

  def draw
    @state_manager.draw
  end

  def button_down(id)
    @state_manager.button_down(id)
  end
end

Main.new.show
