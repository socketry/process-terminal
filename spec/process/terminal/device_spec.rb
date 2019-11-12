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

require "process/terminal/device"

RSpec.describe Process::Terminal::Device do
	subject {Process::Terminal::Device.open}
	
	describe '.open' do
		it "can open default tty" do
			expect(subject).to_not be_nil
		end
		
		context "with invalid path" do
			subject {Process::Terminal::Device.open("does/not/exist")}
			
			it "does not open tty" do
				expect(subject).to be_nil
			end
		end
	end
	
	it "can set foreground process" do
		process = IO.popen("irb", pgroup: true)
		subject.foreground = process.pid
		
		expect(subject.foreground).to be == process.pid
		
		Process.kill(:TERM, process.pid)
		Process.waitpid(process.pid)
	end
end
