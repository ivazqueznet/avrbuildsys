# Copyright (c) 2015 Ignacio Vazquez-Abrams
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

BASEDIR=$(CURDIR)/$(dir $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
AS=$(AVRPATH)avr-as
CC=$(AVRPATH)avr-gcc
CXX=$(AVRPATH)avr-c++
CXXFLAGS=$(EXTRAFLAGS) -Wall -Wextra -Wno-main -mmcu=$(MCU) -Os -I$(BASEDIR)/include -L$(BASEDIR)/lib/avr$(AVRARCH)
CFLAGS=$(CXXFLAGS)
ASFLAGS=$(CFLAGS)
OBJCOPY=$(AVRPATH)avr-objcopy
SIZE=$(AVRPATH)avr-size

DEVICESLIST=$(BASEDIR)/devices.lst

MCU:=$(shell awk -F : '$$1 == "$(DEVICE)" { print $$2 }' $(DEVICESLIST))
MCUSHORT:=$(shell awk -F : '$$1 == "$(DEVICE)" { print $$3 }' $(DEVICESLIST))
PROGRAMMER:=$(shell awk -F : '$$1 == "$(DEVICE)" { print $$4 }' $(DEVICESLIST))
AVRDUDEOPTS:=$(shell awk -F : '$$1 == "$(DEVICE)" { print $$5 }' $(DEVICESLIST))
ifndef F_CPU
F_CPU:=$(shell awk -F : '$$1 == "$(DEVICE)" { print $$6 }' $(DEVICESLIST))
endif

ifdef F_CPU
EXTRAFLAGS+=-D F_CPU=$(F_CPU)
endif

AVRARCH:=$(shell $(CC) -E $(CFLAGS) - <<< "__AVR_ARCH__" | tail -n 1)

all: $(BINARY)
	@$(SIZE) $<

$(BINARY): $(OBJECTS)

clean:
	@rm -f $(BINARY) $(BINARY).o $(BINARY).hex $(OBJECTS) $(EXTRACLEAN)

upload: $(BINARY).hex
	@avrdude -c $(PROGRAMMER) -p $(MCUSHORT) $(AVRDUDEOPTS) -U flash:w:$<:i

fuses:
	@avrdude -c $(PROGRAMMER) -p $(MCUSHORT) $(AVRDUDEOPTS) -U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h -q -q

%.hex: %
	@$(OBJCOPY) -j .text -j .data -O ihex $< $@

.PHONY: all clean upload fuses

