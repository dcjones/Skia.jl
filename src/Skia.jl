
module Skia

using Compat, Color

export Surface, Canvas, Paint, SkRect, SkPoint

const libskia = "/Users/dcjones/prj/Skia.jl/src/libskia.dylib"

const UNKNOWN_SK_COLORTYPE = 0
const RGBA_8888_SK_COLORTYPE = 1
const BGRA_8888_SK_COLORTYPE = 2
const ALPHA_8_SK_COLORTYPE = 3

const OPAQUE_SK_ALPHATYPE = 0
const PREMUL_SK_ALPHATYPE = 1
const UNPREMUL_SK_ALPHATYPE = 2


# mirroring sk_imageinfo_t
immutable SkImageInfo
    width::Int32
    height::Int32
    colorType::Cint
    alhpaType::Cint
end


# mirroring sk_point_t
immutable SkPoint
    x::Float32
    y::Float32
end


# mirroring sk_rect_t
immutable SkRect
    left::Float32
    top::Float32
    right::Float32
    bottom::Float32
end


type Surface
    ptr::Ptr{Void}

    function Surface(width::Int, height::Int)
        imageinfo = SkImageInfo(width, height,
                                RGBA_8888_SK_COLORTYPE, PREMUL_SK_ALPHATYPE)
        surface = new(ccall((:sk_surface_new_raster, libskia), Ptr{Void},
                            (Ptr{SkImageInfo},), &imageinfo))
        finalizer(surface, destroy)
        return surface
    end
end


function destroy(surface::Surface)
    # TODO: It's not clear how to dispose of this
end


function pngdata(surface::Surface)
    image = ccall((:sk_surface_new_image_snapshot, libskia), Ptr{Void},
                  (Ptr{Void},), surface.ptr)
    imagedata = ccall((:sk_image_encode, libskia), Ptr{Void}, (Ptr{Void},), image)

    len = ccall((:sk_data_get_size, libskia), Csize_t, (Ptr{Void},),
                imagedata)
    dataptr = ccall((:sk_data_get_data, libskia), Ptr{Uint8}, (Ptr{Void},),
                    imagedata)
    data = Array(Uint8, len)
    unsafe_copy!(pointer(data, 1), dataptr, len)

    ccall((:sk_data_unref, libskia), Void, (Ptr{Void},), imagedata)
    ccall((:sk_image_unref, libskia), Void, (Ptr{Void},), image)

    return data
end


# Paint controls how paths are drawn
type Paint
    ptr::Ptr{Void}

    function Paint()
        paint = new(ccall((:sk_paint_new, libskia), Ptr{Void}, ()))

        #ccall((:sk_paint_set_antialias, libskia), Void, (Ptr{Void}, Cchar),
              #paint.ptr, true)

        finalizer(paint, destroy)
        return paint
    end
end

function destroy(paint::Paint)
    if paint.ptr != C_NULL
        ccall((:sk_paint_delete), Void, (Ptr{Void},), paint.ptr)
        paint.ptr = C_NULL
    end
end


function set_color(paint::Paint, color::ColorValue)
    ccall((:sk_paint_set_color, libskia), Void, (Ptr{Void}, Uint32),
          paint.ptr, convert(Uint32, convert(ARGB32, color)))

end



# Cavas
type Canvas
    ptr::Ptr{Void}

    function Canvas(surface::Surface)
        canvas = new(ccall((:sk_surface_get_canvas, libskia), Ptr{Void},
                           (Ptr{Void},), surface.ptr))
        finalizer(canvas, destroy)
        return canvas
    end
end


function destroy(canvas::Canvas)
    # TODO: Nor is it clear how to dispose of this
end


function draw_rect(canvas::Canvas, rect::SkRect, paint::Paint)
    ccall((:sk_canvas_draw_rect, libskia), Void,
          (Ptr{Void}, Ptr{SkRect}, Ptr{Void}),
          canvas.ptr, &rect, paint.ptr)
end


function draw_circle(canvas::Canvas, cx::Real, cy::Real, radius::Real,
                     paint::Paint)
    ccall((:sk_canvas_draw_circle, libskia), Void,
          (Ptr{Void}, Float32, Float32, Float32, Ptr{Void}),
          canvas.ptr, cx, cy, radius, paint.ptr)
end


function draw_oval(canvas::Canvas, rect::SkRect, paint::Paint)
    ccall((:sk_canvas_draw_oval, libskia), Void,
          (Ptr{Void}, Ptr{SkRect}, Ptr{Void}),
          canvas.ptr, &rect, paint.ptr)
end





# TODO: set stroke, color, etc


end # module Skia

