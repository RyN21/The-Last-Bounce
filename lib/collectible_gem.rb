class CollectibleGem
  attr_reader :x, :y, :frames

  def initialize(frames, x, y)
    @x, @y             = x, y
    @frames            = frames
    @frame_count       = 4
    @current_frame     = 0
    @frame_delay       = 100
    @last_frame_change = Gosu.milliseconds
  end

  def update
    current_time = Gosu.milliseconds
    if current_time - @last_frame_change > @frame_delay
      @current_frame = (@current_frame + 1) % @frame_count
      @last_frame_change = current_time
    end
  end

  def draw(camera_x, camera_y)
    screen_x = @x - camera_x
    screen_y = @y - camera_y
    @frames[@current_frame].draw_rot(screen_x, screen_y, 0, 25 * Math.sin(Gosu.milliseconds / 133.7), 0.5, 0.5, 1.75, 1.75)
  end
end
