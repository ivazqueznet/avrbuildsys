# avrbuildsys

This is a small setup for a GCC-based AVR buildsys allowing for file-based
selection of devices and alternate buildchains.

`devices.lst` contains the set of AVR devices the buildsys will acknowledge
in the makefile.

`Makefile.tmpl` is the template to copy into a new subdirectory of `avr/`
(as `Makefile`) for the project. The new `Makefile` must be edited
appropriately before it can be used.

The makefile commands (run in the new directory) are:

    make
    make all        Build the binary and show the resultant size
    make clean      Delete built binary, hex file, and object files
    make upload     Upload the hex file using avrdude
    make fuses      Display the MCU's current fuse values
