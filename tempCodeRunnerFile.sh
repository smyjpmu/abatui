f $(lspci | grep -i "VGA compatible controller: Advanced Micro Devices" > /dev/null 2>&1); then
			echo "AMD (i)GPU found, drivers will be installed"
			amd_pkg="xf86-video-amdgpu vulkan-radeon libva-mesa-driver"
		else
			amd_pkg=""
		fi
	}

# unmounting drives
	unmount_drive () {
		echo "-==Unmounting Drives==-"
		if grep -qs '/mnt/boot 