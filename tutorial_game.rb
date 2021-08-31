# $stdout.sync = true
require 'gosu'
# require 'date'

class Tutorial < Gosu::Window
  def initialize
      super 640, 480 #,:fullscreen => true 
      self.caption = "Tutorial Game"         
      @background_image = Gosu::Image.new("media/space.png", :tileable => true)
      @from_text = Gosu::Image.from_text("The xfce mouse", 11, :bold => true)  
      @player = Player.new
      @player.warp(320, 240)  

      # Gosu::Image.load_tiles(source, tile_width, tile_height, options[:tileable => true, false | :retro => true,  false])
      @star_anim = Gosu::Image.load_tiles("media/star.png", 25, 25)
      @stars = Array.new

      # Gosu::Font.new(size, font-family)
      @font = Gosu::Font.new(20)

      @tmp = 0

      #new additions
      @tmp2 = 0
      @counter = Gosu::Font.new(20)
      @init_time = Time.now.sec
  end  
  
  def update
      # Gosu.button_down? check for button input, here we get input from keyboard left and gamepad left
      if Gosu.button_down? Gosu::KB_LEFT #or Gosu::button_down? Gosu::GP_LEFT
          @player.turn_left 
      end
      
      # Gosu.button_down? check for button input, here we get input from keyboard right and gamepad right
      @player.turn_right if Gosu.button_down? Gosu::KB_RIGHT #or Gosu::button_down? Gosu::GP_RIGHT  
      # here we wait for the button_down callback and accelerate our player forward
      @player.accelerate if Gosu.button_down? Gosu::KB_UP #or Gosu::button_down? Gosu::GP_BTTON_0
      
      @player.move
      @player.collect_stars(@stars)
      
      if rand(100) < 4 and @stars.size < 25
          @stars.push(Star.new(@star_anim))
      end  
      @tmp += 3
      @tmp = 0 if @tmp > 640

      if Time.now.sec != @init_time
        @tmp2 += 1
        @init_time = Time.now.sec
      end

  end
  
  def draw
      @background_image.draw(0, 0, 0)
      @player.draw
      @from_text.draw(@tmp,0, 1)  
      @stars.each{ |star| star.draw }
      # draw_text(text, x, y, z, scale_x, scale_y, color, mode = :default) (x,y)position starts from top left
      @font.draw_text("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)

      #new additions
      @counter.draw_text("Time:#{@tmp2}",550, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
  end

=begin 
  Similar to update() and draw(),
  Gosu::Window provides two member functions button_down(id) and button_up(id) which can be overridden.
=end
  # assign escape key to close the game
  def button_down(btn)
    if btn == Gosu::KB_ESCAPE
      close 
    else
      #  The default implementation of Gosu::Window#button_down
      # lets the user toggle between fullscreen and windowed mode with alt+enter (Windows, Linux) or cmd+F (macOS) .
      # Because we want to keep this default behaviour, we call super if the user has not pressed anything that 
      # interests us.
      super
    end
  end
end

class Player
  def initialize
    @image = Gosu::Image.new("media/starfighter.bmp")

    #sound sample, Gosu::Sample.new(source)
    @beep = Gosu::Sample.new("media/beep.wav")

    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def score
    @score
  end

  def collect_stars(stars)
    # deletes the star object if the ditance from it to the player is less than 35 pixels
    stars.reject! do |star| 
      # Gosu.distance returns distance from (x1, y1) to (x2, y2)
      if Gosu.distance(@x, @y, star.x, star.y) < 35 
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end   

=begin 
  Player#accelerate makes use of the offset_x/offset_y functions, which are similar to the mathematical sin/cos  functions.
  If something moved 100 pixels per frame at an angle of 30°,
  it would move by offset_x(30, 100) (=50) [sin(30)*100] pixels horizontally,
  and by offset_y(30, 100) (=-86.6) [cos(30)*100] pixels vertically each frame.
=end  
  def accelerate
    @vel_x += Gosu.offset_x(@angle, 0.5)
    @vel_y += Gosu.offset_y(@angle, 0.5)
  end  

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480  
    @vel_x *= 0.95
    @vel_y *= 0.95
  end 

  def draw
    @image.draw_rot(@x, @y, 1, @angle) # draw-rotaion(x, y, z, angle) the (x,y) start from the middle of the screen
  end
end

class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color::BLACK.dup     # duplicated the Gosu black color object
    @color.red = rand(256 -40) + 40     # random dark red value
    @color.green = rand(256 -40) + 40   # random dark green value
    @color.blue = rand(256 -40) + 40    # random dark blue value
    @x = rand * 640
    @y = rand * 480
  end

  def draw
    img = @animation[Gosu.milliseconds / 100 % @animation.size]
    # img.draw(x, y, z, scale_x, scale_y, color[Gosu::Color, Integer], mode[:default, :additive])
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0, ZOrder::STARS, 1, 1, @color, :add)
  end
end

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end


Tutorial.new.show
