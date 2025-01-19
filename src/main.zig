export fn _start() void {
    while (true) {
        asm volatile ("hlt");
    }
}
