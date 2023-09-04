#!/bin/sh
set -e

rm -r ./*.bin_u/ || true

/app/wt_ext_cli unpack_vromf --input_dir_or_file aces.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file atlases.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file char.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file game.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file gui.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file images.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file lang.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file mis.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file tex.vromfs.bin &
/app/wt_ext_cli unpack_vromf --input_dir_or_file wwdata.vromfs.bin &

wait

find ./ -type f -name "*.blk" -exec sh -c 'mv "$1" "${1%.blk}.blkx"' _ {} \;

rm ./*.vromfs.bin

wine64 /win/ddsx_unpack.exe ./
find . -name "*.ddsx" -delete

find tex.vromfs.bin_u/ -type f -name "*.dds" -exec mogrify -format png -define png:exclude-chunk=date,time "{}" \; &
find images.vromfs.bin_u/ -type f -name "*.dds" -exec mogrify -format png -define png:exclude-chunk=date,time "{}" \; &
find atlases.vromfs.bin_u/ -type f -name "*.dds" -exec mogrify -format png -define png:exclude-chunk=date,time "{}" \; &

wait

find . -name "*.dds" -delete
