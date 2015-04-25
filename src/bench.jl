
using Color, Cairo, Skia

function skia_draw(filename, width, height, n, r)
    surface = Surface(width, height)
    canvas = Canvas(surface)
    paint = Paint()

    Skia.set_color(paint, color("#aaa"))
    Skia.draw_rect(canvas, SkRect(0.0, 0.0, width, height), paint)

    Skia.set_color(paint, color("steel blue"))

    for _ in 1:n
        x, y = width * rand(), height * rand()
        Skia.draw_circle(canvas, x, y, r, paint)
        #rect = SkRect(x - r/2, y - r/2, x + r/2, y + r/2)
        #Skia.draw_oval(canvas, rect, paint)
    end

    out = open(filename, "w")
    write(out, Skia.pngdata(surface))
    close(out)
end

function cairo_draw(filename, width, height, n, r)
    surface = CairoImageSurface(width, height, Cairo.FORMAT_ARGB32)
    context = CairoContext(surface)

    c = color("#aaa")
    set_source_rgba(context, c.r, c.g, c.b, 1.0)
    rectangle(context, 0, 0, width, height)
    fill(context)

    c = color("steel blue")
    set_source_rgba(context, c.r, c.g, c.b, 1.0)

    for _ in 1:n
        x, y = width * rand(), height * rand()
        circle(context, x, y, r)
        fill(context)
    end

    out = open(filename, "w")
    write_to_png(surface, out)
    close(out)
end

width = 500
height = 500
n = 1000000
r = 3.0

skia_draw("skia.png", width, height, n, r)
@time skia_draw("skia.png", width, height, n, r)

cairo_draw("cairo.png", width, height, n, r)
@time cairo_draw("cairo.png", width, height, n, r)





