--==============================================================================
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--==============================================================================
--------------------------------------------------------------------------------
-- REQUIRES
--------------------------------------------------------------------------------
local cyrpto=require('crypto')
--------------------------------------------------------------------------------
-- FIELDS
--------------------------------------------------------------------------------
-- Public
local core = {}
-- Private
--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------
-- Public
function core.isAndroid()
	return "Android"==system.getInfo("platformName")
end

function core.isIOS()
	 return "iPhone OS"==system.getInfo("platformName")
end

function core.isCoronaSimulator()
	return "simulator"==system.getInfo("environment") or
				 "Mac OS X"==system.getInfo("platformName") or
				 "Win"==system.getInfo("platformName")
end

function core.isXCodeSimulator()
	return system.getInfo("model")=="iPhone Simulator" or
				 system.getInfo("model")=="iPad Simulator"
end

function core.isSimulator()
	return core.isCoronaSimulator() or core.isXcodeSimulator()
end

function core.coronaBuild()
	return tonumber(system.getInfo("build"):match("[.](.-)$"))
end

function core.md5String(text)
	return crypto.digest( crypto.md5, text )
end

function core.version()
	print "Pubnative v1.0.0"
end
-- Private
--------------------------------------------------------------------------------
return core
--==============================================================================
