.phony: uinitrd

# need uboot-mkimage installed...should really just get it from u-boot directory
uinitrd: bootimage ramdisk
	@-mkdir -p $(PRODUCT_OUT)/boot
	mkimage -A arm -O linux -T ramdisk -C gzip -d $(PRODUCT_OUT)/ramdisk.img $(PRODUCT_OUT)/boot/uInitrd
