# MIT License
#
# Copyright (c) 2025 gjbauer
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

# These instructions assume the user is running a standard Arch Linux system on x86_64
# If using a different environment, please make the necessary changes
# Future changes may include multi-platform build support

# Install dependecies

OS=$(uname -s)

case "$OS" in
    Linux)
	echo "Operating System: Linux"
		if [ -f /etc/os-release ]; then
			source /etc/os-release
			if [ "$ID" = "arch" ]; then
				echo "Supported Linux distribution: Arch Linux!!"
				
				DEPENDENCIES="git clang base-devel python python-pip acpica dosfstools util-linux"
				echo "Updating repositories..."
				if ! sudo pacman -Sy > /dev/null 2>&1; then
					echo "Failed to update repositories!!"
					return 1
				fi
				echo "Checking dependencies..."
				for pkg in $DEPENDENCIES; do
					if ! pacman -Qi "$pkg" > /dev/null 2>&1; then
						echo "Installing missing dependency: $pkg"
						if ! sudo pacman -S --noconfirm "$pkg" > /dev/null 2>&1; then
							echo "Failed to install package!!"
							return 1
						fi
					else
						echo "Dependency already installed: $pkg"
					fi
				done
            elif [ "$ID" = "linuxmint" ]; then
                echo "Supported Linux distribution: Linux Mint!!"
				
				DEPENDENCIES="git clang build-essential python3 python3-pip acpica-tools dosfstools uuid-dev"
				echo "Updating repositories..."
				if ! sudo apt update > /dev/null 2>&1; then
					echo "Failed to update repositories!!"
					return 1
				fi
				echo "Checking dependencies..."
				for pkg in $DEPENDENCIES; do
					if ! dpkg -s "$pkg" > /dev/null 2>&1; then
						echo "Installing missing dependency: $pkg"
						if ! sudo apt install -y "$pkg" > /dev/null 2>&1; then
							echo "Failed to install package!!"
							return 1
						fi
					else
						echo "Dependency already installed: $pkg"
					fi
				done
			else
				echo "Unsupported Linux distribution! returning..."
				return 1
			fi
		else
			echo "Cannot find release information!! returning..."
			return 1
		fi
	;;
    Darwin)
	echo "Operating System: macOS"
	echo "Unsupported OS: returning!"
	return 1
	;;
    FreeBSD)
	echo "Operating System: FreeBSD"
	echo "Unsupported OS: returning!"
	return 1
	;;
    CYGWIN*|MINGW32*|MSYS*)
	echo "Operating System: Windows (via Cygwin/MinGW/MSYS)"
	echo "Unsupported OS: returning!"
	return 1
	;;
    *)
	echo "Operating System: Unknown ($OS)"
	echo "Unsupported OS: returning!"
	return 1
	;;
esac

# Clone EDK2 repo
if [ -d "edk2" ]; then
	echo "EDK II directory exists!! Assuming repository and subdirectories already pulled! Continuing..."
	echo "If this is incorrect, please delete the directory and try again..."
	cd edk2
else
	echo "Cloning EDK II repository and submodules..."
	git clone https://github.com/tianocore/edk2.git --depth 1 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Repository pull failed!!"
		return 1
	fi
	cd edk2
	git submodule update --init --depth 1 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Submodule pull failed!!"
		return 1
	fi
fi

# Build BaseTools (with Clang)
echo "Building base tools..."
export CC=clang
export CXX=clang++
make -C BaseTools > build-log.txt 2>&1
if [ $? -ne 0 ]; then
	echo "Build failed!! Check build log for details..."
	echo "Consider running 'tail build-log.txt'"
	return 1
else
	rm build-log.txt
fi

# Configure the build environment
echo "Setting up development environment"
source ./edksetup.sh BaseTools > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Setup failed!!"
	return 1
fi

cd ..

echo "EDK2 environment setup completed successfully!"
