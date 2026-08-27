import os

hw_c_path = "/Users/abagher/Documents/GitHub/watch-calc-32/Firmware/hardware_wrapper.c"
with open(hw_c_path, "r") as f:
    content = f.read()

# Replace PIN defines
content = content.replace(
"""#define PIN_CS   17
#define PIN_SCK  18
#define PIN_MOSI 19""",
"""#define PIN_CS   17
#define PIN_SCK  18
#define PIN_MOSI 19
#define PIN_DC   21
#define PIN_RST  20"""
)

# Replace buffer size
content = content.replace("uint8_t buffer[12000];", "uint8_t buffer[1024];")
content = content.replace("for (int i = 0; i < 12000; i++) {", "for (int i = 0; i < 1024; i++) {")

# Replace hw_init for SPI
spi_init_old = """    spi_init(SPI_PORT, 1000 * 1000); 
    
    // According to datasheet, Sharp expects LSB first.
    spi_set_format(SPI_PORT, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_LSB_FIRST);

    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    gpio_init(PIN_CS);
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 0); // CS is active HIGH for Sharp Memory LCD

    // Start 1Hz timer for VCOM toggle
    add_repeating_timer_ms(1000, vcom_timer_callback, NULL, &vcom_timer);"""

spi_init_new = """    spi_init(SPI_PORT, 8000 * 1000); // ST7567 can run at 8MHz
    
    spi_set_format(SPI_PORT, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);

    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    gpio_init(PIN_CS);
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 1); // CS active LOW

    gpio_init(PIN_DC);
    gpio_set_dir(PIN_DC, GPIO_OUT);
    gpio_put(PIN_DC, 0);

    gpio_init(PIN_RST);
    gpio_set_dir(PIN_RST, GPIO_OUT);
    gpio_put(PIN_RST, 1);

    // ST7567 Reset
    gpio_put(PIN_RST, 0);
    sleep_ms(50);
    gpio_put(PIN_RST, 1);
    sleep_ms(50);

    // ST7567 Init Sequence
    gpio_put(PIN_CS, 0);
    gpio_put(PIN_DC, 0); // Command mode
    uint8_t init_cmds[] = {
        0xE2, // Soft reset
        0x2C, 0x2E, 0x2F, // Power ON
        0xF8, 0x00, // Booster 4X
        0x22, // Resistor ratio
        0x81, 0x20, // Contrast
        0xA2, // 1/9 bias
        0xC8, // COM direction
        0xA0, // SEG direction
        0xA4, // Normal display
        0xA6, // Non-inverted
        0x40, // Start line 0
        0xAF  // Display ON
    };
    spi_write_blocking(SPI_PORT, init_cmds, sizeof(init_cmds));
    gpio_put(PIN_CS, 1);"""

content = content.replace(spi_init_old, spi_init_new)

# Remove vcom
content = content.replace("""volatile uint8_t vcom_state = 0;
struct repeating_timer vcom_timer;

bool vcom_timer_callback(struct repeating_timer *t) {
    vcom_state ^= 0x02; // Toggle VCOM bit (bit 1)
    
    // Send VCOM toggle command
    uint8_t cmd[2] = { vcom_state, 0x00 };
    gpio_put(PIN_CS, 1);
    spi_write_blocking(SPI_PORT, cmd, 2);
    gpio_put(PIN_CS, 0);
    
    return true;
}""", "")

# Replace display_send_buffer
send_buf_old = """    gpio_put(PIN_CS, 1);
    
    uint8_t mode = 0x01 | vcom_state; // Update Line mode
    spi_write_blocking(SPI_PORT, &mode, 1);
    
    for (int y = 0; y < 240; y++) {
        uint8_t line_addr = y + 1; // 1-indexed
        spi_write_blocking(SPI_PORT, &line_addr, 1);
        
        // 50 bytes per line
        spi_write_blocking(SPI_PORT, buffer + (y * 50), 50);
        
        uint8_t dummy = 0x00;
        spi_write_blocking(SPI_PORT, &dummy, 1); // Trailer per line
    }
    
    uint8_t dummy = 0x00;
    spi_write_blocking(SPI_PORT, &dummy, 1); // Final trailer
    
    gpio_put(PIN_CS, 0);"""

send_buf_new = """    gpio_put(PIN_CS, 0);
    
    for (int p = 0; p < 8; p++) {
        gpio_put(PIN_DC, 0); // Command
        uint8_t page_cmd[] = { (uint8_t)(0xB0 | p), 0x10, 0x00 };
        spi_write_blocking(SPI_PORT, page_cmd, 3);
        
        gpio_put(PIN_DC, 1); // Data
        spi_write_blocking(SPI_PORT, buffer + (p * 128), 128);
    }
    
    gpio_put(PIN_CS, 1);"""
content = content.replace(send_buf_old, send_buf_new)

with open(hw_c_path, "w") as f:
    f.write(content)

print("hw patched")
