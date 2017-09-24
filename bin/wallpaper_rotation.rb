#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'rmagick'
require 'macos_utility'

CURRENT_FILE_DELIMINATOR = "__CURRENT__"

def get_idx_charater(string, character)
  (0...string.length).select {|i| string[i] == character}
end

# get rotation folder from input arguments
wallpaper_dir = ARGV[0]

# return unless directory argument given
return unless File.directory?(wallpaper_dir)

wallpaper_list = Dir["#{wallpaper_dir}/*"].select do |file|
  !file.match(/#{CURRENT_FILE_DELIMINATOR}/) && (['jpg', 'jpeg', 'png', 'tiff', 'pict'].include? file.match(/.([\w]*)$/)[1].downcase)
end

next_image_idx = Random.new.rand(wallpaper_list.length-1)
next_image_path = wallpaper_list[next_image_idx]

contents = nil
File::open(next_image_path,'r') do |file|
  file.flock(File::LOCK_SH)
  contents = file.read
end

idxs = get_idx_charater(next_image_path, '.')
path = next_image_path.insert(idxs[idxs.length-1], CURRENT_FILE_DELIMINATOR)

File::open(path, 'w+') do |file|
  file.write(contents)
end

ruby_process = MacosUtility.get_processes(process_name: 'rubymine')
atom_process = MacosUtility.get_processes(process_name: 'Atom')

if atom_process
  message = "You are wasting %%cpu:#{atom_process.cpu} and %%mem:#{atom_process.mem} on Atom!"
elsif ruby_process
  message = "RubyMine: %%cpu:#{ruby_process.cpu} %%mem:#{ruby_process.mem}"
else
  message = "RubyMine not running, get back to code!"
end

img = Magick::Image.read(path).first
watermark_text = Magick::Draw.new
watermark_text.annotate(img, 0,0,0,0, message) do
  self.gravity = Magick::SouthGravity
  self.pointsize = img.columns / 35
  self.font = "/Users/joshuawilkosz/GitHub/wallpaper_rotation/public/fonts/Ubuntu-R.ttf"
  self.stroke = "none"
  self.fill = "white"
end
img.write(path)
# open with image magick and write some text
MacosUtility.change_desktop_background(path)

# clean up existing file
Dir["#{wallpaper_dir}/*"].each do |file|
  File.delete(file) if path != file && file.match(/#{CURRENT_FILE_DELIMINATOR}/)
end

# ENV
# /Users/joshuawilkosz/.rvm/wrappers/ruby-2.4.0/ruby

# FILE
# /Users/joshuawilkosz/GitHub/wallpaper_rotation/wallpaper_rotation.rb

# ARGUMENTS
# /Users/joshuawilkosz/GitHub/wallpaper_rotation/rotation_folder

# CRONTAB
# */10 * * * * /Users/joshuawilkosz/.rvm/wrappers/ruby-2.4.0/ruby /Users/joshuawilkosz/GitHub/wallpaper_rotation/bin/wallpaper_rotation.rb /Users/joshuawilkosz/GitHub/wallpaper_rotation/public/rotation_folder

