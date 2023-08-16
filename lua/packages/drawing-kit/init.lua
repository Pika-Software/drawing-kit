if SERVER then
    resource.AddWorkshop( "2996887024" )
    return
end

install( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )

local surface = surface
local render = render
local string = string
local math = math
local draw = draw
local hook = hook
local cam = cam

local STUDIO_RENDER = STUDIO_RENDER
local LocalToWorld = LocalToWorld
local angle_zero = angle_zero
local Material = Material
local select = select
local Color = Color

local screenWidth, screenHeight = util.ScreenResolution()
hook.Add( "ScreenResolutionChanged", "ScreenResolution", function( w, h )
    screenWidth, screenHeight = w, h
end )

module( "dk", package.seeall )

for key, value in pairs( draw ) do
    if key == "_PACKAGE" then continue end
    if key == "_NAME" then continue end
    if key == "_M" then continue end
    _M[ key ] = value
end

-- Aliases
TexturedRectRotated = surface.DrawTexturedRectRotated
TexturedRectUV = surface.DrawTexturedRectUV
OutlinedRect = surface.DrawOutlinedRect
GetTextureSize = surface.GetTextureSize
TexturedRect = surface.DrawTexturedRect
GetAlpha = surface.GetAlphaMultiplier
SetClipping = render.EnableClipping
GetTextColor = surface.GetTextColor
SetTextColor = surface.SetTextColor
GetTexture = surface.GetTextureID
SetMaterial = surface.SetMaterial
RoundedBoxEx = draw.RoundedBoxEx
GetColor = surface.GetDrawColor
SetColor = surface.SetDrawColor
SetTexture = surface.SetTexture
GetTextPos = surface.GetTextPos
SetTextPos = surface.SetTextPos
SetTextFont = surface.SetFont
RoundedBox = draw.RoundedBox
NoTexture = draw.NoTexture
Rect = surface.DrawRect
Line = surface.DrawLine
Poly = surface.DrawPoly

function SetAlpha( alpha )
    local old = GetAlpha()
    surface.SetAlphaMultiplier( alpha )
    return old
end

-- Gradient (by Klen-list)
do

    local material = Material( "gui/gradient", "smooth" )

    function Gradient( x, y, w, h )
        SetMaterial( material )
        TexturedRect( x, y, w, h )
    end

end

do

    local material = Material( "gui/gradient_down", "smooth" )

    function GradientDown( x, y, w, h )
        SetMaterial( material )
        TexturedRect( x, y, w, h )
    end

end

do

    local material = Material( "gui/gradient_up", "smooth" )

    function GradientUp( x, y, w, h )
        SetMaterial( material )
        TexturedRect( x, y, w, h )
    end

end

do

    local material = Material( "gui/center_gradient", "smooth" )

    function GradientCenter( x, y, w, h )
        SetMaterial( material )
        TexturedRect( x, y, w, h )
    end

end

-- Circles (by Retr0)
do

    local quaterCircleMaterial = Material( "gui/quater_circle.png", "ignorez mips smooth" )
    local circleMaterial = Material( "gui/circle.png", "ignorez mips smooth" )

    function Circle( x, y, r, color )
        if color then
            SetColor( color:Unpack() )
        end

        local size = r * 2
        SetMaterial( circleMaterial )
        TexturedRect( x - r, y - r, size, size )
    end

    function CircleBoxEx( x, y, w, h, color, tl, tr, bl, br )
        if color then
            SetColor( color:Unpack() )
        end

        SetMaterial( quaterCircleMaterial )

        local quater = math.min( w / 2, h / 2 )
        Rect( x + quater, y, w - quater * 2, h )
        Rect( x, y + quater, quater, h - quater * 2 )
        Rect( x + w - quater, y + quater, quater, h - quater * 2 )

        if tl then
            TexturedRectUV( x, y, quater, quater, 0, 0, 1, 1 )
        else
            Rect( x, y, quater, quater )
        end

        if tr then
            TexturedRectUV( x + w - quater, y, quater, quater, 1, 0, 0, 1 )
        else
            Rect( x + w - quater, y, quater, quater )
        end

        if bl then
            TexturedRectUV( x, y + h - quater, quater, quater, 0, 1, 1, 0 )
        else
            Rect( x, y + h - quater, quater, quater )
        end

        if br then
            TexturedRectUV( x + w - quater, y + h - quater, quater, quater, 1, 1, 0, 0 )
        else
            Rect( x + w - quater, y + h - quater, quater, quater )
        end
    end

    function CircleBox( x, y, w, h, color )
        CircleBoxEx( x, y, w, h, color, true, true, true, true )
    end

end

-- Blur
do

    local blur = Material( "pp/blurscreen" )

    function Blur( amount, x, y, w, h, alpha )
        SetMaterial( blur )

        for i = 1 / amount, 1, 1 / amount do
            blur:SetInt( "$blur", 10 * i )
            render.UpdateScreenEffectTexture()
            SetColor( 0, 0, 0, alpha or 255 )
            Poly( {
                {
                    ["x"] = x,
                    ["y"] = y,
                    ["u"] = x / screenWidth,
                    ["v"] = y / screenHeight
                },
                {
                    ["x"] = w,
                    ["y"] = y,
                    ["u"] = w / screenWidth,
                    ["v"] = y / screenHeight
                },
                {
                    ["x"] = w,
                    ["y"] = h,
                    ["u"] = w / screenWidth,
                    ["v"] = h / screenHeight
                },
                {
                    ["x"] = x,
                    ["y"] = h,
                    ["u"] = x / screenWidth,
                    ["v"] = h / screenHeight
                }
            } )
        end
    end

end

-- Text
function GetTextSize( text, font )
    if font then
        surface.SetFont( font )
    end

    return surface.GetTextSize( text )
end

do

    local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
    local TEXT_ALIGN_BOTTOM = TEXT_ALIGN_BOTTOM
    local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT

    function SimpleText( text, font, x, y, color, xAlign, yAlign )
        if color then
            SetTextColor( color:Unpack() )
        end

        local w, h = GetTextSize( text, font )
        if xAlign == TEXT_ALIGN_CENTER then
            x = x - w / 2
        elseif xAlign == TEXT_ALIGN_RIGHT then
            x = x - w
        end

        if yAlign == TEXT_ALIGN_CENTER then
            y = y - h / 2
        elseif yAlign == TEXT_ALIGN_BOTTOM then
            y = y - h
        end

        SetTextPos( math.ceil( x ), math.ceil( y ) )
        surface.DrawText( text )
        return w, h
    end

end

function Text( text, font, x, y, color, xAlign, yAlign )
    local curX = x
    local curY = y

    if font then surface.SetFont( font ) end
    local lineHeight = select( 2, surface.GetTextSize( "\n" ) )
    local tabWidth = 50

    for str in string.gmatch( text, "[^\n]*" ) do
        if #str == 0 then
            curY = curY + lineHeight / 2
            curX = x
            continue
        end

        if not string.find( str, "\t" ) then
            SimpleText( str, nil, curX, curY, color, xAlign, yAlign )
            continue
        end

        for tabs, str2 in string.gmatch( str, "(\t*)([^\t]*)" ) do
            curX = math.ceil( ( curX + tabWidth * math.max( #tabs - 1, 0 ) ) / tabWidth ) * tabWidth

            if #str2 > 0 then
                SimpleText( str2, nil, curX, curY, color, xAlign, yAlign )
                curX = curX + surface.GetTextSize( str2 )
            end
        end
    end
end

do

    local shadowColors = {}

    function ShadowText( text, font, x, y, color, xAlign, yAlign, depth, shadow )
        shadow = shadow or 50

        for i = 1, depth do
            local shadowColor = shadowColors[ i * shadow ]
            if not shadowColor then
                shadowColor = Color( 0, 0, 0, i * shadow )
            end

            SimpleText( text, font, x + i, y + i, shadowColor, xAlign, yAlign )
        end

        SimpleText( text, font, x, y, color, xAlign, yAlign )
    end

end

function DualText( title, subtitle, x, y, h )
    x, y = x or 0, y or 0

    local tH = select( 2, GetTextSize( title[1], title[2] ) )
    local sH = select( 2, GetTextSize( subtitle[1], subtitle[2] ) )

    DrawShadowText( title[1], title[2], x, y - sH / 2, title[3], title[4], 1, title[5], title[6] )
    DrawShadowText( subtitle[1], subtitle[2], x, y + tH / 2, subtitle[3], subtitle[4], 1, subtitle[5], subtitle[6] )
end

-- https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_util.lua
do

    local textWrapCache = {}

    local function charWrap( text, remainingWidth, maxWidth )
        local totalWidth = 0

        text = string.gsub( text, ".", function( char )
            totalWidth = totalWidth + surface.GetTextSize( char )

            if (totalWidth >= remainingWidth) then
                totalWidth = surface.GetTextSize( char )
                remainingWidth = maxWidth
                return "\n" .. char
            end

            return char
        end )

        return text, totalWidth
    end

    function WrapText( text, width, font )
        local chachedName = text .. width .. font
        if textWrapCache[ chachedName ] then
            return textWrapCache[ chachedName ]
        end

        if font then surface.SetFont( font ) end
        if surface.GetTextSize( text ) <= width then
            textWrapCache[ chachedName ] = text
            return text
        end

        local totalWidth = -1
        local spaceWidth = surface.GetTextSize( " " )
        text = string.gsub( text, "(%s?[%S]+)", function( word )
            local char = string.sub( word, 1, 1 )
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize( word )
            totalWidth = totalWidth + wordlen

            if wordlen >= width then
                local splitWord, splitPoint = charWrap( word, width - ( totalWidth - wordlen ), width )
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < width then
                return word
            end

            if char == " " then
                totalWidth = wordlen - spaceWidth
                return "\n" .. string.sub( word, 2 )
            end

            totalWidth = wordlen
            return "\n" .. word
        end )

        textWrapCache[ chachedName ] = text
        return text
    end

end

do

    local ellipsesTextCache = {}

    function EllipsesText( text, width, font )
        local chachedName = text .. width .. font
        if ellipsesTextCache[ chachedName ] then
            return ellipsesTextCache[ chachedName ]
        end

        if font then surface.SetFont( font ) end
        local textWidth = surface.GetTextSize( text )

        if textWidth <= width then
            ellipsesTextCache[ chachedName ] = text
            return text
        end

        local len = #text
        if len == 0 then
            ellipsesTextCache[ chachedName ] = text
            return text
        end

        for i = 1, len do
            text = string.Trim( string.Left( text, len - i ) )
            textWidth = surface.GetTextSize( text .. "..." )
            if textWidth <= width then break end
        end

        if textWidth <= width then
            text = text .. "..."
        end

        ellipsesTextCache[ chachedName ] = text
        return text
    end

end

-- https://github.com/TomDotBat/pixel-ui
function OutlinedBox( x, y, w, h, thickness, color )
    if color then
        SetColor( color:Unpack() )
    end

    for i = 0, thickness - 1 do
        OutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
    end
end

local roundedBoxCache = {}

function OutlinedRoundedBox( borderSize, x, y, w, h, color, thickness )
    thickness = thickness or 1

    if color then
        SetColor( color:Unpack() )
    end

    if borderSize <= 0 then
        OutlinedBox( x, y, w, h, thickness )
        return
    end

    local fullRight = x + w
    local fullBottom = y + h
    borderSize = borderSize / 2

    local left, right = x + borderSize, fullRight - borderSize
    local top, bottom = y + borderSize, fullBottom - borderSize

    local halfBorder = borderSize * 0.6
    local width, height = w - borderSize * 2, h - borderSize * 2

    -- Left
    Rect( x, top, thickness, height )

    -- Right
    Rect( x + w - thickness, top, thickness, height )

    -- Top
    Rect( left, y, width, thickness )

    -- Bottom
    Rect( left, y + h - thickness, width, thickness)

    local cacheName = borderSize .. x .. y .. w .. h .. thickness
    local cache = roundedBoxCache[ cacheName ]
    if not cache then
        cache = {
            -- Top Right
            {

                -- Outer
                {
                    ["x"] = right,
                    ["y"] = y
                },
                {
                    ["x"] = right + halfBorder,
                    ["y"] = top - halfBorder
                },
                {
                    ["x"] = fullRight,
                    ["y"] = top
                },

                -- Inner
                {
                    ["x"] = fullRight - thickness,
                    ["y"] = top
                },
                {
                    ["x"] = right + halfBorder - thickness,
                    ["y"] = top - halfBorder + thickness
                },
                {
                    ["x"] = right,
                    ["y"] = y + thickness
                }

            },

            -- Bottom Right
            {

                -- Outer
                {
                    ["x"] = fullRight,
                    ["y"] = bottom
                },
                {
                    ["x"] = right + halfBorder,
                    ["y"] = bottom + halfBorder
                },
                {
                    ["x"] = right,
                    ["y"] = fullBottom
                },

                -- Inner
                {
                    ["x"] = right,
                    ["y"] = fullBottom - thickness
                },
                {
                    ["x"] = right + halfBorder - thickness,
                    ["y"] = bottom + halfBorder - thickness
                },
                {
                    ["x"] = fullRight - thickness,
                    ["y"] = bottom
                }

            },

            -- Bottom Left
            {

                -- Outer
                {
                    ["x"] = left,
                    ["y"] = fullBottom
                },
                {
                    ["x"] = left - halfBorder,
                    ["y"] = bottom + halfBorder
                },
                {
                    ["x"] = x,
                    ["y"] = bottom
                },

                -- Inner
                {
                    ["x"] = x + thickness,
                    ["y"] = bottom
                },
                {
                    ["x"] = left - halfBorder + thickness,
                    ["y"] = bottom + halfBorder - thickness
                },
                {
                    ["x"] = left,
                    ["y"] = fullBottom - thickness
                }

            },

            -- Top Left
            {

                -- Outer
                {
                    ["x"] = x,
                    ["y"] = top
                },
                {
                    ["x"] = left - halfBorder,
                    ["y"] = top - halfBorder
                },
                {
                    ["x"] = left,
                    ["y"] = y
                },

                -- Inner
                {
                    ["x"] = left,
                    ["y"] = y + thickness
                },
                {
                    ["x"] = left - halfBorder + thickness,
                    ["y"] = top - halfBorder + thickness
                },
                {
                    ["x"] = x + thickness,
                    ["y"] = top
                }

            }
        }

        roundedBoxCache[ cacheName ] = cache
    end

    NoTexture()

    for i = 1, #cache do
        Poly( cache[ i ] )
    end
end

if not MENU_DLL then

    function EntityEx( data )
        local entity = data.entity
        cam.Start3D( LocalToWorld( entity:GetPos(), angle_zero, data.origin, angle_zero ), data.angles, data.fov, data.x, data.y, data.w, data.h, data.znear, data.zfar )
            entity:DrawModelWithChildren( data.flags or STUDIO_RENDER, data.ignorenodraw )
        cam.End3D()
    end

    do

        local temp = {}

        function Entity( entity, cameraOrigin, x, y, w, h, fov )
            local mins, maxs = entity:GetModelRenderBounds()
            local center = ( mins + maxs ) / 2

            local entityOrigin = mins + center / 4
            entityOrigin[ 1 ] = 0
            entityOrigin[ 2 ] = 0

            temp.angles = ( entityOrigin - cameraOrigin ):Angle()
            temp.origin = cameraOrigin
            temp.x, temp.y = x, y
            temp.w, temp.h = w, h
            temp.entity = entity
            temp.fov = fov

            EntityEx( temp )
        end

    end

    do

        local shouldDrawLocalPlayer = false
        hook.Add( "ShouldDrawLocalPlayer", "Player", function()
            if shouldDrawLocalPlayer then return true end
        end, -1 )

        function PlayerEx( data )
            local entity = data.entity
            local isLocalPlayer = entity:IsLocalPlayer()
            if isLocalPlayer then
                shouldDrawLocalPlayer = true
            end

            cam.Start3D( LocalToWorld( entity:GetPos(), angle_zero, data.origin, angle_zero ), data.angles, data.fov, data.x, data.y, data.w, data.h, data.znear, data.zfar )
                entity:DrawModelWithChildren( data.flags or STUDIO_RENDER, data.ignorenodraw )
            cam.End3D()

            if isLocalPlayer then
                shouldDrawLocalPlayer = false
            end
        end

    end

    do

        local temp = {}

        function Player( entity, cameraOrigin, x, y, w, h, fov )
            local mins, maxs = entity:GetHull()
            local center = ( mins + maxs ) / 2

            local playerOrigin = mins + center
            playerOrigin[ 1 ] = 0
            playerOrigin[ 2 ] = 0

            temp.angles = ( playerOrigin - cameraOrigin ):Angle()
            temp.origin = cameraOrigin
            temp.x, temp.y = x, y
            temp.w, temp.h = w, h
            temp.entity = entity
            temp.fov = fov

            PlayerEx( temp )
        end

    end

end