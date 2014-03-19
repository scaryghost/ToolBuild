#!/usr/bin/env sh

version=$(git describe | sed s/-[^-]*$// | sed s/-/\./)
split=(${version//\./ })
step=0

if [ ${#split[@]} -eq "4" ];
then
    let step+=${split[2]}
    let step+=${split[3]}
    let split[2]=$step
fi

printf "VERSION=%s\nVERSION_MAJOR=%s\nVERSION_MINOR=%s\nVERSION_STEP=%s\n"\
        "${split[0]}.${split[1]}.${split[2]}"\
        "${split[0]}" "${split[1]}" "${split[2]}" > project_version.mk
