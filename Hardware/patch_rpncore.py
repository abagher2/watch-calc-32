import os

renderer_path = "/Users/abagher/Documents/GitHub/watch-calc-32/RPNCore/Sources/RPNCore/Display/Renderer.swift"
with open(renderer_path, "r") as f:
    r_content = f.read()

r_content = r_content.replace("buffer = [UInt8](repeating: 0, count: 12000) // 400x240 memory LCD (50 bytes * 240 rows)", "buffer = [UInt8](repeating: 0, count: 1024) // 128x64 ST7567 (128 cols * 8 pages)")

dp_old = """    public func drawPixel(x: Int, y: Int, color pixelColor: Bool) {
        if x < 0 || x >= 400 || y < 0 || y >= 240 { return }
        
        let byteIndex = (y * 50) + (x / 8)
        // Sharp memory LCD sends bytes LSB first. But let's check the HW driver. 
        // Our font rasterizer generates bits where MSB is the leftmost pixel of that byte.
        // E.g. bit 7 is x%8 == 0
        let bitIndex = 7 - (x % 8)
        
        if pixelColor {
            buffer[byteIndex] |= UInt8(1 << bitIndex)
        } else {
            buffer[byteIndex] &= ~UInt8(1 << bitIndex)
        }
    }"""
    
dp_new = """    public func drawPixel(x: Int, y: Int, color pixelColor: Bool) {
        if x < 0 || x >= 128 || y < 0 || y >= 64 { return }
        
        let page = y / 8
        let bitIndex = y % 8
        let byteIndex = (page * 128) + x
        
        if pixelColor {
            buffer[byteIndex] |= UInt8(1 << bitIndex)
        } else {
            buffer[byteIndex] &= ~UInt8(1 << bitIndex)
        }
    }"""
r_content = r_content.replace(dp_old, dp_new)

r_content = r_content.replace("""    public func getPixel(x: Int, y: Int) -> Bool {
        if x < 0 || x >= 400 || y < 0 || y >= 240 { return false }
        
        let byteIndex = (y * 50) + (x / 8)
        let bitIndex = 7 - (x % 8)
        return (buffer[byteIndex] & UInt8(1 << bitIndex)) != 0
    }""",
"""    public func getPixel(x: Int, y: Int) -> Bool {
        if x < 0 || x >= 128 || y < 0 || y >= 64 { return false }
        
        let page = y / 8
        let bitIndex = y % 8
        let byteIndex = (page * 128) + x
        return (buffer[byteIndex] & UInt8(1 << bitIndex)) != 0
    }""")

r_content = r_content.replace("        let baseW = 400", "        let baseW = 128")
r_content = r_content.replace("        let baseH = 240", "        let baseH = 64")
r_content = r_content.replace("        let midX = 200", "        let midX = 64")
r_content = r_content.replace("        let midY = 120", "        let midY = 32")

r_content = r_content.replace("            let val = min(max(Int(round(plotH - yPos)), 0), 239)", "            let val = min(max(Int(round(plotH - yPos)), 0), 63)")

with open(renderer_path, "w") as f:
    f.write(r_content)


retroui_path = "/Users/abagher/Documents/GitHub/watch-calc-32/RPNCore/Sources/RPNCore/Display/RetroUI.swift"
with open(retroui_path, "r") as f:
    u_content = f.read()

# Downscale layout for 128x64
u_content = u_content.replace("var rightX = 400 - 6", "var rightX = 128 - 2")
u_content = u_content.replace("            renderer.drawString(valStr, x: 400 - textW, y: 40, size: fontToUse, color: true, scale: 1)",
                              "            renderer.drawString(valStr, x: 128 - textW, y: 16, size: fontToUse, color: true, scale: 1)")
u_content = u_content.replace("            renderer.drawString(valStr, x: 400 - 6 - textW, y: 40, size: fontToUse, color: true, scale: 1)",
                              "            renderer.drawString(valStr, x: 128 - 2 - textW, y: 16, size: fontToUse, color: true, scale: 1)")
u_content = u_content.replace("        let menuY = 240 - 20", "        let menuY = 64 - 10")
u_content = u_content.replace("        let menuH = 20", "        let menuH = 10")
u_content = u_content.replace("        let wPerItem = 400 / 6", "        let wPerItem = 128 / 6")

with open(retroui_path, "w") as f:
    f.write(u_content)

print("RPNCore patched")
