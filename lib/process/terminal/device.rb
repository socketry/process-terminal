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
			def self.open(path = "/dev/tty", mode = "r+")
				self.new(File.open(path, mode))
			end
			
			def initialize(io)
				@io = io
			end
			
			def close
				@io.close
				@io = nil
			end
			
			# Make the specified pid the foreground processs in the current terminal.
			# @param pid [Integer] the foreground process group.
			def foreground=(pid)
				current = Signal.trap(:SIGTTOU, :IGNORE)
				
				Unistd.tcsetpgrp(@io.fileno, pid)
			ensure
				Signal.trap(:SIGTTOU, current) if current
			end
			
			# @return [Integer] the foreground process group.
			def foreground
				Unistd.tcgetpgrp(@io.fileno)
			end
		end
	end
end
