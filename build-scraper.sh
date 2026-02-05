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

build -h > /dev/null 2>&1

if [ $? -ne 0 ]; then
	echo "Building EDK2 environment..."
	source ./edk2-build.sh
fi

echo "Pulling ScraperPkg..."

git clone https://github.com/gjbauer/ScraperPkg.git edk2/ScraperPkg --depth 1 > /dev/null 2>&1

echo "Building ScraperPkg for RISC-V..."

build -a RISCV64 --buildtarget RELEASE -p ScraperPkg/ScraperPkg.dsc -t CLANGDWARF > build-log.txt 2>&1

if [ $? -ne 0 ]; then
	echo "Build failed!!"
	echo "Run 'less build-log.txt' to see what went wrong..."
	return 1
else
	echo "ScraperPkg built successfully!!"
	rm build-log.txt
fi

