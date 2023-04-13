#!/bin/sh
set -e

rm -r ./*.bin_u/ || true

python -m wt_tools.vromfs_unpacker aces.vromfs.bin &
python -m wt_tools.vromfs_unpacker atlases.vromfs.bin &
python -m wt_tools.vromfs_unpacker char.vromfs.bin &
python -m wt_tools.vromfs_unpacker game.vromfs.bin &
python -m wt_tools.vromfs_unpacker gui.vromfs.bin &
python -m wt_tools.vromfs_unpacker images.vromfs.bin &
python -m wt_tools.vromfs_unpacker lang.vromfs.bin &
python -m wt_tools.vromfs_unpacker mis.vromfs.bin &
python -m wt_tools.vromfs_unpacker tex.vromfs.bin &
python -m wt_tools.vromfs_unpacker wwdata.vromfs.bin &

wait

rm ./*.vromfs.bin

python -m wt_tools.blk_unpack_ng --format json_3 aces.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 atlases.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 char.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 game.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 gui.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 images.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 lang.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 mis.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 tex.vromfs.bin_u/ &
python -m wt_tools.blk_unpack_ng --format json_3 wwdata.vromfs.bin_u/ &

wait

find . -name "*.blk" -delete


wine64 /app/datamine/win/ddsx_unpack.exe ./
find . -name "*.ddsx" -delete

find tex.vromfs.bin_u/ -name "*.dds" -exec mogrify -format png -define png:exclude-chunk=date,time "{}" \; &
find images.vromfs.bin_u/ -name "*.dds" -exec mogrify -format png -define png:exclude-chunk=date,time "{}" \; &
find atlases.vromfs.bin_u/ -name "*.dds" -exec mogrify -format png -define png:exclude-chunk=date,time "{}" \; &

wait

find . -name "*.dds" -delete
