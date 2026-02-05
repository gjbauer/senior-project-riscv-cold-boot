# MIT License
#
# Copyright (c) 2026 gjbauer
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

echo "Running ScraperPkg build script..."
source ./build-scraper.sh

echo "Building RiscVVirt..."
build -a RISCV64 --buildtarget RELEASE -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t CLANGDWARF > build-log.txt 2>&1

if [ $? -ne 0 ]; then
	echo "Build failed!!"
	echo "Run 'less build-log.txt' to see what went wrong..."
	return 1
else
	echo "RiscVVirt built successfully!!"
	rm build-log.txt
fi

echo "Truncating RiscVVirt files..."

truncate -s 32M edk2/Build/RiscVVirtQemu/RELEASE_CLANGDWARF/FV/RISCV_VIRT_CODE.fd

truncate -s 32M edk2/Build/RiscVVirtQemu/RELEASE_CLANGDWARF/FV/RISCV_VIRT_VARS.fd

echo "Generating raw image of UEFI application..."

LOOP_DEVICE=$(sudo losetup -f)
dd if=/dev/zero of=scraper.img bs=1M count=4096 status=progress
sudo losetup "$LOOP_DEVICE" scraper.img
sudo sgdisk -Z "$LOOP_DEVICE" && sudo sgdisk -n 0:0:0 "$LOOP_DEVICE"
sudo partprobe "$LOOP_DEVICE"
sudo mkfs.fat -F32 "$LOOP_DEVICE"p1
mkdir mnt
sudo mount -o loop "$LOOP_DEVICE"p1 mnt
sudo mkdir -p mnt/EFI/BOOT
sudo cp edk2/Build/ScraperPkg/RELEASE_CLANGDWARF/RISCV64/ScraperPkg.efi mnt/EFI/BOOT/bootriscv64.efi
sudo umount mnt
sudo losetup -d "$LOOP_DEVICE"
rmdir mnt

echo "Running QEMU test..."
echo "Ensure that the memory dumps to 100%..."

qemu-system-riscv64 \
 -M virt,pflash0=pflash0,pflash1=pflash1,acpi=off \
 -m 2048 -smp 2 \
 -device virtio-gpu-pci \
 -device qemu-xhci \
 -device usb-kbd \
 -device virtio-rng-pci \
 -blockdev node-name=pflash0,driver=file,read-only=on,filename=edk2/Build/RiscVVirtQemu/RELEASE_CLANGDWARF/FV/RISCV_VIRT_CODE.fd \
 -blockdev node-name=pflash1,driver=file,filename=edk2/Build/RiscVVirtQemu/RELEASE_CLANGDWARF/FV/RISCV_VIRT_VARS.fd \
 -netdev user,id=net0 \
 -device virtio-net-pci,netdev=net0 \
 -drive file=scraper.img,format=raw,id=hd0

