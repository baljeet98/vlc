--[[
    Translate MegaVideo video webpages URLs to the corresponding FLV URL.

 $Id$

 Copyright © 2008 the VideoLAN team

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]

-- Probe function.
function probe()
    return vlc.access == "http"
        and string.match( vlc.path, "megavideo.com" ) 
end

-- Parse function.
function parse()

    -- we have to get the xml
    if string.match( vlc.path, "www.megavideo.com.*&v=.*&u=.*" ) then
        id = string.gsub( vlc.path, "www.megavideo.com.*v=([^&]*).*$", "%1" )
        path = "http://www.megavideo.com/xml/videolink.php?v=" .. id
        return { { path = path } }
    end

    while true
    do 
        line = vlc.readline()
        if not line then break end

        -- we got the xml
        if string.match( line, "<ROWS><ROW url=\"" )
        then
            xml = ""
            while line do
                -- buffer the full xml
                xml = xml .. line
                line = vlc.readline()
            end
            -- now gets the encoded url
            s = string.gsub( xml, ".*ROW url=\"([^\"]*).*", "%1" )
            path = ""
            i = 1
            while s:byte(i) do
                c = s:byte(i)
                if c % 4 < 2 then
                    if c < 16 and c > 3 then key = 61
                    elseif c < 96 and c > 67 then key = 189
                    elseif c < 20 and c > 6 then key = 65
                    else vlc.msg_err("Oops, please report URL to developers")
                    end
                else
                    if c < 16 and c > 3 then key = 65
                    elseif c < 96 and c > 67 then key = 193
                    elseif c < 20 and c > 6 then key = 65
                    else vlc.msg_err("Oops, please report URL to developers")
                    end
                end
                i = i + 1
                path = path .. string.char(key - c)
            end
        end
        if path then break end
    end
    print( path )
    if path then
        return { { path = path } }
    else
        return { }
    end
end
