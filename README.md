# Reinstall Windows from Linux

**PROBLEM:** How to install Windows when no KVM or BMC is available.

# Auto grub config

```
{
  curl -L# https://raw.githubusercontent.com/rjsocha/windows-install-from-linux/refs/heads/master/grub/install | bash -s
}
```

# Usage

```
{
curl -o /boot/ipxe-chain.bios -# http://http.install.socha.it/windows/boot/ipxe-chain.bios
curl -o /boot/ipxe-chain.efi -# http://http.install.socha.it/windows/boot/ipxe-chain.efi
}
```

Modify grub.cfg (add as first entry)

```
menuentry 'windows-install' {
  insmod part_gpt
  insmod part_msdos
  insmod ext2
  if [ "$grub_platform" = "efi" ]; then
    chainloader /ipxe-chain.efi
  else
    linux16 /ipxe-chain.bios
  fi
}
```

## ipxe

```
apt-get update
apt-get install -y build-essential syslinux mkisofs isolinux liblzma-dev
```

```
git clone https://github.com/ipxe/ipxe.git
cd ipxe/src
make
```

```
# Copy and modify chain.ipxe
curl -OL# https://raw.githubusercontent.com/rjsocha/windows-install-from-linux/refs/heads/master/ipxe/embed/chain.ipxe
make bin/ipxe.lkrn EMBED=chain.ipxe
make bin-x86_64-efi/ipxe.efi EMBED=chain.ipxe
```

Copy bin/ipxe.lkrn and bin-x86_64-efi/ipxe.efi:
```
cp bin/ipxe.lkrn /boot/ipxe-chain.bios
cp bin-x86_64-efi/ipxe.efi /boot/ipxe-chain.efi
```

## Prepare HTTP server

Download Windows Server 2025 Evaluation ISO:

```
  curl -OL# https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso
```


Download Windows Server 2022 Evaluation ISO:

```
  curl -OL# https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso
```

Extract **bcd** and **boot.sdi** from ISO:

```
mkdir extract boot
sudo mount -o loop SERVER_EVAL_x64FRE_en-us.iso extract/
cp extract/boot/bcd boot/
cp extract/boot/boot.sdi boot/
sudo umount extract && rm -rf -- extract
```

Download **wimboot**:
```
curl -OL# https://github.com/ipxe/wimboot/releases/latest/download/wimboot
```

## Prepare boot.wim (Under Windows OS)

Download or copy Windows Server 2022 Evaluation ISO and extrat boot.wim from **sources/boot.wim**

Mount boot.wim and copy files from **dism** directory. Modify **auto.cmd** and set INSTALL variable:

```
mkdir boot
dism /mount-wim /wimfile:boot.wim /index:2 /mountdir:boot
xcopy /s dism\ boot\
dism /unmount-wim /mountdir:boot /commit
```

Copy modified **boot.wim** to HTTP server (to the same place where **bcd** and **boot.sdi** files were copied)


## Add drivers

```
mkdir install
dism /mount-Wim /wimfile:install.wim /index:4 /mountdir:install
dism /image:install /add-driver /driver:git\driver\virtio\2025 /recurse
:: Optional
dism /image:install /remove-capability /capabilityname:AzureArcSetup~~~~
dism /unmount-wim /mountdir:install /commit
```

## Export only DC image

```
dism /export-image /sourceimagefile:install.wim /sourceindex:4 /destinationimagefile:install-dc.wim /compress:max
```

# For better compression

https://wimlib.net/

```
wimlib-imagex export install-dc.wim 1 install.wim --compress=LZMS --solid
```


# Boot

## Modify grub.cfg (add as first entry)

```
menuentry 'windows-install' {
  insmod part_gpt
  insmod part_msdos
  insmod ext2
  if [ "$grub_platform" = "efi" ]; then
    chainloader /ipxe-chain.efi
  else
    linux16 /ipxe-chain.bios
  fi
}
```

##  Alternative (grub2 bios)

```
linux16 /windows/wimboot quiet
initrd16 newc:winpeshl.ini:/windows/wyga/wyga.ini newc:wyga.cmd:/windows/wyga/wyga.cmd newc:wyga.cab:/windows/wyga/wyga.cab newc:bcd:/windows/
2025/bcd newc:boot.sdi:/windows/2025/boot.sdi newc:boot.wim:/windows/2025/boot.wim
```
