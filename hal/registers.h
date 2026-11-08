

// gpio pins
#define GPIO_ENABLE_REG          ((volatile unsigned int *)(0x60004020))
#define GPIO_OUT_REG             ((volatile unsigned int *)(0x60004004))

// --- Memory-Mapped Register Map for Watchdogs (WDT) ---
#define TIMG_WDTCONFIG0_REG     ((volatile unsigned int *)(0x6001F048))
#define TIMG_WDTFEED_REG        ((volatile unsigned int *)(0x6001F060))
#define TIMG_WDTWPROTECT_REG    ((volatile unsigned int *)(0x6001F064))
#define TIMG_INT_CLR_TIMERS_REG        ((volatile unsigned int *)(0x6001F07C))

// RTC Watchdog (RWDT) registers
#define RTC_CNTL_WDTCONFIG0_REG ((volatile unsigned int *)(0x60008090))
#define RTC_CNTL_WDTWPROTECT_REG ((volatile unsigned int *)(0x600080A8))

// Super Watchdog (SWD) registers — ESP32-C3 has its own separate WPROTECT
#define RTC_CNTL_SWD_CONF_REG      ((volatile unsigned int *)(0x600080AC))
#define RTC_CNTL_SWD_WPROTECT_REG  ((volatile unsigned int *)(0x600080B0))

// jtag registors
#define USB_SERIAL_JTAG_EP1_REG ((volatile unsigned int *)(0x60043000))
#define USB_SERIAL_JTAG_EP1_CONF_REG ((volatile unsigned int *)(0x60043004))