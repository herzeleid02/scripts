#!/bin/bash

build_root="/tmp/iso-$(date +%d%m%Y)-$(tr -dc a-z </dev/urandom | head -c 4)"
chroot_dir=""
output_iso=""
v_keya=""
verbosity=0
arg_mode=0 # 0 == pass args as is; 1 == use options

trap "failure_cleanup" 1 2 3 6

function main(){
	while getopts "hvd:o:" option; do
	#while getopts ":h" option; do
		case $option in
			h) greeter_help
				exit;;
			v) verbosity=1;;
			d) chroot_dir=$(realpath $OPTARG)
				arg_mode=1
				echo "${chroot_dir}";;
			o) output_iso=$(realpath $OPTARG)
				arg_mode=1
				echo "${output_iso}";;
			\?) greeter_help;;
		esac
	done

	if [ $OPTIND -eq 1 ]; then
		#echo "no options" # debug
		assign_args "$@"
	elif [ $1 = "-v" ] && [ ${arg_mode} == 0 ]; then
		echo "feed"
		shift 1
		assign_args "$@"
	fi
	arg_parser "$@"

	init_flags
	check_chroot

	if [ ${verbosity} == 1 ]; then
		make_iso
	else
		make_iso &> /dev/null
	fi
	
	make_iso  # the master building function

}

function arg_parser(){
	if [ -z ${chroot_dir} ] || [ -z ${output_iso} ]; then
		greeter_help
	fi
}

function assign_args(){
		chroot_dir=$(realpath $1 2> /dev/null)
		output_iso=$(realpath $2 2> /dev/null)
}

function greeter_help(){
	echo "Usage:"
	echo "$0 <options>"
	echo "$0 source output"
	echo "$0 -d source -o output"
	echo "$0 -v source output"
	exit 1
}

function failure_cleanup(){
	rm ${v_keya} -rf ${build_root}
	exit 1
}



### the core functionality begins here



function init_flags(){
	if [ ${verbosity} == 1 ]; then
	v_keya="-v"
	#echo "$v_keya" # debug
	fi
}

function check_chroot(){
	if [ ! -e ${chroot_dir}/bin/sh ] || [ ! -e ${chroot_dir}/boot/vmlinuz ]; then
	echo "No /bin/sh or kernel image found, aborting..."
	exit 1
	fi
}

# the master nested function -- look below
function make_iso(){
	make_hierarchy
	make_squashfs
	copy_kernel
	boot_menu_isolinux
	boot_menu_grub
	boot_install_isolinux
	boot_install_grub
	create_iso
}



### functions after this line should be nested into one trapped function (make_iso) (!!!)



function make_hierarchy(){
	### hacky solution -- i just link the chroot directory instead of rewriting the entire script
	#echo $build_root # debug
	mkdir ${v_keya} -p ${build_root}/{staging/{EFI/BOOT,boot/grub/x86_64-efi,isolinux,live},tmp}
	cp -r ${v_keya} ${chroot_dir} ${build_root}/

	#ln ${v_keya} -s "${chroot_dir}" "${build_root}/chroot" ## ln doesnt work here, u either mount or cp the directory :(
	### WHY cp -- its safer to first copy the chroot and then build the squashfs image: you can modify the OG chroot and it wont break (did cp)
	### WHY mount -- because... it could leave to lesser RAM usage
}

function make_squashfs(){
	mksquashfs \
    "${build_root}/chroot" \
    "${build_root}/staging/live/filesystem.squashfs" \
    -e boot
}

function copy_kernel(){
	cp "${build_root}/chroot/boot"/vmlinuz* \
		"${build_root}/staging/live/" && \
	cp "${build_root}/chroot/boot"/initrd* \
	"${build_root}/staging/live/"
}

function boot_menu_isolinux(){
	cat <<'EOF' > "${build_root}/staging/isolinux/isolinux.cfg"
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 600
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Astra Linux SE Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live

LABEL linux
  MENU LABEL Astra Linux SE Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF
}

function boot_menu_grub(){
cat <<'EOF' > "${build_root}/staging/boot/grub/grub.cfg"
insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660

insmod all_video
insmod font

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Astra Linux SE Live [EFI/GRUB]" {
    search --no-floppy --set=root --label DEBLIVE
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd.img
}

menuentry "Astra Linux SE Live [EFI/GRUB] (nomodeset)" {
    search --no-floppy --set=root --label DEBLIVE
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd.img
}
EOF
	cp "${build_root}/staging/boot/grub/grub.cfg" "${build_root}/staging/EFI/BOOT/"

## something weird
cat <<'EOF' > "${build_root}/tmp/grub-embed.cfg"
if ! [ -d "$cmdpath" ]; then
    # On some firmware, GRUB has a wrong cmdpath when booted from an optical disc.
    # https://gitlab.archlinux.org/archlinux/archiso/-/issues/183
    if regexp --set=1:isodevice '^(\([^)]+\))\/?[Ee][Ff][Ii]\/[Bb][Oo][Oo][Tt]\/?$' "$cmdpath"; then
        cmdpath="${isodevice}/EFI/BOOT"
    fi
fi
configfile "${cmdpath}/grub.cfg"
EOF

}

function boot_install_isolinux(){
	cp ${v_keya} /usr/lib/ISOLINUX/isolinux.bin "${build_root}/staging/isolinux/" && \
	cp ${v_keya} /usr/lib/syslinux/modules/bios/* "${build_root}/staging/isolinux/"
}

function boot_install_grub(){
	# TODO: remove i386(?)
	grub-mkstandalone -O i386-efi \
    --modules="part_gpt part_msdos fat iso9660" \
    --locales="" \
    --themes="" \
    --fonts="" \
    --output="${build_root}/staging/EFI/BOOT/BOOTIA32.EFI" \
    "boot/grub/grub.cfg=${build_root}/tmp/grub-embed.cfg"
	grub-mkstandalone -O x86_64-efi \
    --modules="part_gpt part_msdos fat iso9660" \
    --locales="" \
    --themes="" \
    --fonts="" \
    --output="${build_root}/staging/EFI/BOOT/BOOTx64.EFI" \
    "boot/grub/grub.cfg=${build_root}/tmp/grub-embed.cfg"

	# TODO: change `cd` to something more graceful
	(cd "${build_root}/staging" && \
    dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img ::/EFI ::/EFI/BOOT && \
    mcopy -vi efiboot.img \
        "${build_root}/staging/EFI/BOOT/BOOTIA32.EFI" \
        "${build_root}/staging/EFI/BOOT/BOOTx64.EFI" \
        "${build_root}/staging/boot/grub/grub.cfg" \
        ::/EFI/BOOT/
)
}

function create_iso(){
	# TODO: replace "DEBLIVE"
	xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "${output_iso}" \
    -full-iso9660-filenames \
    -volid "DEBLIVE" \
    --mbr-force-bootable -partition_offset 16 \
    -joliet -joliet-long -rational-rock \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e --interval:appended_partition_2:all:: \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xEF ${build_root}/staging/efiboot.img \
    "${build_root}/staging"
}

    #-append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B ${build_root}/staging/efiboot.img \
    # i replaced big EFI GUID to this `0xEF` thing (old xorriso hack, newer xorriso builds work just fine)


main "$@"
