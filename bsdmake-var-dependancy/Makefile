# Makefile for bootstrap-image

VERSION=        1.0.0.0A
TRAIN=          CURRENT
ARCH=           amd64
GEOM_SIZE_MB=   8192
SWAP_SIZE=      1G

BOOT_OPTIONS += legacy-boot
BOOT_OPTIONS += efi-auto 
BOOT_OPTIONS += efi-bootmgr

FS_OPTIONS   += bootflash-fs
FS_OPTIONS   += nvram-fs
FS_OPTIONS   += swap-fs
FS_OPTIONS   += dev-fs


#################################################################################

ESOSROOT!=      realpath `pwd | grep -o '^.*\/esos\/'`
STAGE:=        ${ESOSROOT}/stage

BOOTSTRAP=      bootstrap-${VERSION}-${TRAIN}-${ARCH}
BOOT_IMAGE_0=  ${STAGE}/${BOOTSTRAP}-flash0.img
BOOT_IMAGE_1=  ${STAGE}/${BOOTSTRAP}-flash1.img

BOOTSTRAP_EFI= ${BOOTSTRAP}.efi

LOADER_RC=     ${BOOT_MOUNT}/bootflash/loader.rc
LOADER_CONF=   ${BOOT_MOUNT}/bootflash/loader.conf

BOOT_VDEV=      vflash 

BOOT_MOUNT:=   ${STAGE}/bootstrap
EFI_MOUNT:=    ${STAGE}/efiboot





MD_DEV_0 !=     mdconfig -lv | grep -F "${BOOT_IMAGE_0}" | grep -oE '^md[0-9]+' 
MD_DEV_1 !=     mdconfig -lv | grep -F "${BOOT_IMAGE_1}" | grep -oE '^md[0-9]+'
.if empty(MD_DEV_0) 
.undef MD_DEV_0
MD_DEV_0 =      UNKNOWN_MD_DEV_0
.endif
.if empty(MD_DEV_1)
.undef MD_DEV_1
MD_DEV_1 =      UNKNOWN_MD_DEV_1
.endif


#############################################################################################
##### ENTRY-POINT 

all: output-env ${FS_OPTIONS} ${BOOT_OPTIONS}

output-env:
	@echo ""
	@echo "ESOSROOT: ${ESOSROOT}"
	@echo "STAGE: ${STAGE}"
	@echo "BOOT_MOUNT: ${BOOT_MOUNT}"
	@echo "EFI_MOUNT: ${EFI_MOUNT}"
	@echo ""
	@echo "BOOT_IMAGE_0: ${BOOT_IMAGE_0} "
	@echo "BOOT_IMAGE_1: ${BOOT_IMAGE_1} "
	@echo ""
	

#############################################################################################
##### IMAGE/MD(4) SETUP 


$(BOOT_IMAGE_0): 
	@echo "### Creating image file: ${BOOT_IMAGE_0}..."
	dd if=/dev/zero of="${BOOT_IMAGE_0}" bs=1k count=${GEOM_SIZE_MB}k
	@echo ""
	
$(BOOT_IMAGE_1): 
	@echo "### Creating image file: ${BOOT_IMAGE_1}..."
	dd if=/dev/zero of="${BOOT_IMAGE_1}" bs=1k count=${GEOM_SIZE_MB}k
	@echo ""

##########################################
#### NOTE: VARIABLE IS NOT GETTING SET!!!!

$(MD_DEV_0): ${BOOT_IMAGE_0}
	@echo "### CREATE FILE BACKED md(4) ON ${BOOT_IMAGE_0}..."
	/sbin/mdconfig -a -t vnode -f ${BOOT_IMAGE_0}
	@echo "MADE IT!!!"
	@echo "MD_DEV_0: ${MD_DEV_0}"

$(MD_DEV_1): ${BOOT_IMAGE_1}
	@echo "### CREATE FILE BACKED md(4) ON ${BOOT_IMAGE_1}..."
	/sbin/mdconfig -a -t vnode -f ${BOOT_IMAGE_1}
	@echo "MD_DEV_1: ${MD_DEV_1}"


#############################################################################################
##### PARTITION SETUP 

bootimage-table0: ${MD_DEV_0}
	@echo "### PARTITION ${MD_DEV_0} -> ${BOOT_IMAGE_0}..."
	gpart create -s gpt ${MD_DEV_0}
	gpart add -s 10M                -t efi          -l efiboot0   		${MD_DEV_0}
	gpart add -s 512K             	-t freebsd-boot -l biosboot0  		${MD_DEV_0}
	gpart add -s                    -t freebsd-zfs  -l ${BOOT_VDEV}0    	${MD_DEV_0}
	@echo ""

bootimage-table1: ${MD_DEV_1}
	@echo "### PARTITION ${MD_DEV_1} -> ${BOOT_IMAGE_1}..."
	gpart create -s gpt ${MD_DEV_1}
	gpart add -s 10M                -t efi          -l efiboot1   		${MD_DEV_1}
	gpart add -s 512K             	-t freebsd-boot -l biosboot1  		${MD_DEV_1}
	gpart add -s                    -t freebsd-zfs  -l ${BOOT_VDEV}1    	${MD_DEV_1}
	@echo ""

/dev/gpt/efiboot0: bootimage-table0 
/dev/gpt/biosboot0: bootimage-table0
/dev/gpt/$(BOOT_VDEV)0: bootimage-table0

/dev/gpt/efiboot1: bootimage-table1
/dev/gpt/biosboot1: bootimage-table1
/dev/gpt/$(BOOT_VDEV)1: bootimage-table1


#############################################################################################
##### EFI/BIOS BOOT SETUP 

$(EFI_MOUNT):
	@echo "### BUILD PATH TO STAGE MOUNTPOINT ${EFI_MOUNT}..."
	mkdir -p ${EFI_MOUNT}
	@echo ""

$(BOOTSTRAP_EFI):
	@echo ""
	.error "!!! Please provide $(BOOTSTRAP_EFI) into ${ESOSROOT}/syskit/bootstrap/ !!!"
	@echo ""

/dev/mirror/efiboot: /dev/gpt/efiboot0 /dev/gpt/efiboot1 ${EFI_MOUNT}
	@echo "### MIRROR THE EFI DISKS"
	kldload geom_mirror
	gmirror label -v efiboot /dev/gpt/efiboot0 /dev/gpt/efiboot1
	newfs_msdos /dev/mirror/efiboot
	mount -t msdosfs /dev/mirror/efiboot ${EFI_MOUNT}
	@echo ""

$(EFI_MOUNT)/efi/boot/BOOTx64.efi: ${EFI_MOUNT} ${BOOTSTRAP_EFI} /dev/mirror/efiboot
	mkdir -p ${EFI_MOUNT}/efi/boot
	cp ${BOOTSTRAP_EFI} ${EFI_MOUNT}/efi/boot/BOOTx64.efi

legacy-boot: /dev/gpt/biosboot0 /dev/gpt/biosboot1
	@echo "### INSTALL BOOTCODE TO ALLOW SYSTEM TO BOOT ON LEGACY SYSTEMS (BIOS)..."
	gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 2 ${MD_DEV_0}
	gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 2 ${MD_DEV_1}
	@echo ""

efi-auto: $(EFI_MOUNT)/efi/boot/BOOTx64.efi

efi-bootmgr: /dev/mirror/efiboot
	@echo "### CONFIGURING EFIBOOTMGR TO ALLOW BOOT FROM EITHER FLASH DISK..."
	kldload efirt
	mkdir -p ${EFI_MOUNT}/efi/esos
	cp ${BOOTSTRAP_EFI} ${EFI_MOUNT}/efi/esos
	efibootmgr -c -L ${BOOT_VDEV}0 -l ${MD_DEV_0}p1:/efi/esos/${BOOTSTRAP_EFI}
	efibootmgr -c -L ${BOOT_VDEV}1 -l ${MD_DEV_1}p1:/efi/esos/${BOOTSTRAP_EFI}
	efibootmgr -a 1
	efibootmgr -a 2
	efibootmgr -o 1,2
	@echo ""


#############################################################################################
##### BOOTFLASH 

$(BOOT_MOUNT):
	@echo "### BUILD PATH TO STAGE MOUNTPOINT ${BOOT_MOUNT}..."
	mkdir -p ${BOOT_MOUNT}
	@echo ""

zpool: /dev/gpt/${BOOT_VDEV}0 /dev/gpt/${BOOT_VDEV}1 ${BOOT_MOUNT}
	@echo "### CREATE ZPOOL ${BOOT_VDEV}..."
	zpool create \
	  -R ${BOOT_MOUNT} \
	  -o cachefile=/tmp/zpool.cache \
	  -O mountpoint=/ \
	  -O atime=off \
	  -O canmount=off \
	  -O compression=on \
	  ${BOOT_VDEV} mirror /dev/gpt/${BOOT_VDEV}0 /dev/gpt/${BOOT_VDEV}1
	@echo ""

$(BOOT_MOUNT)/bootflash: zpool
	@echo "### CREATE BASE ZFS HEIRARCHY IN ${BOOT_VDEV}..."
	zfs create -o canmount=off 	-o mountpoint=none 	${BOOT_VDEV}/BE
	zfs create 			-o mountpoint=/		${BOOT_VDEV}/BE/default
	zfs create 						${BOOT_UDEV}/BE/default/bootflash
	@echo ""
	@echo "### MARK ${BOOT_VDEV}/BE/default FOR BOOT..."
	zpool set bootfs=${BOOT_VDEV}/BE/default ${BOOT_VDEV}
	@echo ""

$(LOADER_RC): ${BOOT_MOUNT}/bootflash
	@echo "### CREATE ${LOADER_RC}..."
	mkdir -p ${BOOT_MOUNT}/bootflash
	@echo unload > ${BOOT_MOUNT}/bootflash/${LOADER_RC}
	@echo set currdev=zfs:root/ROOT/default: >> ${BOOT_MOUNT}/bootflash/${LOADER_RC}
	# ---------------------------------------------
	# -- MUST COMPILE sv WITH ZFS MODULE BUILTIN --
	@echo load boot/kernel/kernel >> ${BOOT_MOUNT}/bootflash/${LOADER_RC}
	@echo load boot/kernel/zfs.ko >> ${BOOT_MOUNT}/bootflash/${LOADER_RC}
	# ---------------------------------------------
	@echo load boot/sv-1.0(0)0A >> $(BOOT_MOUNT)/bootflash/${LOADER_RC}
	@echo autoboot >> ${BOOT_MOUNT}/bootflash/${LOADER_RC}

$(LOADER_CONF): ${BOOT_MOUNT}/bootflash
	@echo "### CREATE ${LOADER_CONF}..."
	@echo zfs_load="YES" >> ${BOOT_MOUNT}/bootflash/${LOADER_CONF}
	@echo vfs.root.mountfrom="zfs:${BOOT_VDEV}/BE/default" >> ${BOOT_MOUNT}/bootflash/${LOADER_CONF} 

bootflash-fs: ${LOADER_RC} ${LOADER_CONF}


#############################################################################################
##### NVRAM/SWAP/DEVFS

$(BOOT_MOUNT)/nvram: zpool
	@echo "### CREATE NVRAM ZVOL..."
	zfs create 			-o mountpoint=/nvram 	${BOOT_VDEV}/nvram
	@echo ""
	
/dev/zvol/$(BOOT_VDEV)/swap: zpool
	@echo "### CREATE SWAP ZVOL..."
	PAGESIZE != getconf PAGESIZE
	zfs create -V ${SWAP_SIZE_MB} -b ${PAGESIZE} \
	  -o compression=zle \
	  -o logbias=throughput \
	  -o sync=always \
	  -o primarycache=metadata \
	  -o secondarycache=none \
	  -o com.sun:auto-snapshot=false \
	  ${BOOT_VDEV}/swap
	mkswap -f /dev/zvol/${BOOT_VDEV}/swap
	@echo ""
	# fstab-line: /dev/zvol/${BOOT_VDEV}/swap none swap defaults 0 0
	# enable swap at some point once booted: swapon -av

nvram-fs: $(BOOT_MOUNT)/nvram

swap-fs: /dev/zvol/$(BOOT_VDEV)/swap

dev-fs: zpool
	@echo "### BUILD DEVFS..."
	 mkdir -p ${BOOT_MOUNT}/dev
	 mount -t devfs none ${BOOT_MOUNT}/dev
	@echo ""

#############################################################################################
##### DEPLOYMENT/CLEANUP

stage-umount:
	-umount ${BOOT_MOUNT}/dev
	-umount ${EFI_MOUNT}
	-zpool export ${BOOT_VDEV}
	-mdconfig -d -u ${MD_DEV_0}
	-mdconfig -d -u ${MD_DEV_1}

deploy: all stage-umount
	cp "${BOOT_IMAGE_0}" ${REPO}
	cp "${BOOT_IMAGE_1}" ${REPO}

clean: stage-umount
	-rm -f ${BOOT_IMAGE_0}
	-rm -f ${BOOT_IMAGE_1}

