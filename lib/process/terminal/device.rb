# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'unistd'

module Process
	module Terminal
		class Device
			# Attempts to open the current TTY. Prefer `.new?` if possible.
			# @returns [Device | nil] the terminal device if the file was readable.
			def self.open(path = "/dev/tty", mode = "r+")
				if File.readable?(path)
					self.new(File.open(path, mode))
				end
			end
			
			# Create a new device instance, but only if the supplied IO is a TTY.
			def self.new?(io = STDIN)
				if io.tty?
					self.new(io)
				end
			end
			
			def initialize(io = STDIN)
				@io = io
			end
			
			# Make the specified pid the foreground processs in the current terminal.
			# @param pid [Integer] the foreground process group.
			def foreground=(pid)
				current = Signal.trap(:SIGTTOU, :IGNORE)
				
				result = Unistd.tcsetpgrp(@io.fileno, pid)
				
				if result == -1
					raise SystemCallError.new('tcsetpgrp', FFI.errno)
				end
			ensure
				Signal.trap(:SIGTTOU, current) if current
			end
			
			# @return [Integer] the foreground process group.
			def foreground
				result = Unistd.tcgetpgrp(@io.fileno)
				
				if result == -1
					raise SystemCallError.new('tcgetpgrp', FFI.errno)
				end
				
				return result
			end
		end
	end
end
