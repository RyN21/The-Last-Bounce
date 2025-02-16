# require "gosu"
# # require_relative "lib/game_window"
# # require_relative "lib/state_manager"
#
#
#
# class Main < Gosu::Window
#   def initialize
#     super Config::WINDOW_WIDTH,
#           Config::WINDOW_HEIGHT,
#           Config::FULLSCREEN
#     self.caption = Config::CAPTION
#     Gosu.enable_undocumented_retrofication
#     @state_manager = StateManager.new(self)
#     @state_manager.switch_to(Menu.new(@state_manager))
#   end
#
#   def update
#     @state_manager.update
#   end
#
#   def draw
#     @state_manager.draw
#   end
#
#   def button_down(id)
#     @state_manager.button_down(id)
#   end
# end
#
#
# Main.new.show
