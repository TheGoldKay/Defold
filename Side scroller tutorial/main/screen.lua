-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.
local screen = {}

local ffi = package.preload.ffi()
local bit = require("bit")
local user32 = ffi.load("user32")

ffi.cdef[[
	typedef void* HWND;
	typedef unsigned long DWORD;
	typedef unsigned char BYTE;
	typedef bool BOOL;
	typedef long LONG;

	HWND FindWindowA(const char* lpClassName, const char* lpWindowName);
	BOOL SetWindowLongA(HWND hWnd, int nIndex, DWORD dwNewLong);
	BOOL SetLayeredWindowAttributes(HWND hWnd, DWORD crKey, BYTE bAlpha, DWORD dwFlags);
	DWORD GetWindowLongA(HWND hWnd, int nIndex); 
	int GetSystemMetrics(int nIndex);
]]

function rgb2long(r, g, b)
	if type(r) == "table" then
		r, g, b = unpack(r)
	end 
	return b* 256 * 256 + g * 256 + r
end

function screen:resolution()
	local hwnd = user32.FindWindowA(nil, "def1")
	return {w = user32.GetSystemMetrics(0), h = user32.GetSystemMetrics(1)}
end

function setWindowTransparent(window_name, transparent_color)
	if transparent_color == nil then
		transparent_color = 0
	elseif type(transparent_color) == "table" then 
		transparent_color = rgb2long(transparent_color)
	end 
	-- Constants
	local GWL_EXSTYLE = -20
	local WS_EX_LAYERED = 0x80000
	local LWA_COLORKEY = 0x1
	local ALPHA = 255

	-- Get the handle of the love2d window (its ID)
	local hwnd = user32.FindWindowA(nil, window_name)
	-- window transparency
	-- you can also set to a color you won't use in your game
	-- for that change the background color before calling this function and also use the same color below (LONG format)
	local exStyle = bit.bor(user32.GetWindowLongA(hwnd, GWL_EXSTYLE), WS_EX_LAYERED)
	user32.SetWindowLongA(hwnd, GWL_EXSTYLE, exStyle)
	-- when setting the color (love.graphics.setColor) for drawing use anything other than transparent_color
	user32.SetLayeredWindowAttributes(hwnd, transparent_color, ALPHA, LWA_COLORKEY)
end 

return screen