# Recursively require subdirectories
Dir.glob("#{File.expand_path File.dirname __FILE__}/**/**.rb"){ |file| require file unless File.directory?(file) }