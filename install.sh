#!/bin/bash
# Rclone variables
_rclone_version="v1.45"
rclone_release="rclone-${_rclone_version}-linux-amd64"
rclone_zip="${rclone_release}.zip"
rclone_url="https://github.com/ncw/rclone/releases/download/${_rclone_version}/${rclone_zip}"

# Rclone
wget "$rclone_url"
unzip "$rclone_zip"
chmod a+x "${rclone_release}/rclone"
cp -rf "${rclone_release}/rclone" "/usr/bin/rclone"
rm -rf "$rclone_zip"
rm -rf "$rclone_release"
