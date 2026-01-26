# Configure the build environment
echo "Setting up development environment"

cd edk2

source ./edksetup.sh BaseTools > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Setup failed!!"
	return 1
fi

cd ..

echo "EDK2 environment setup completed successfully!"
