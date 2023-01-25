# prebuild-apps-in-lineage-
This script builds in custom apps on the fly while compiling lineage. The apps are currently downloaded from the repo.

Copy this script in your lineage repo dir "lineage_build_unified" and link this in file "buildbot_unified.sh", function "build_treble" after "lunch ...":

"build_treble() {
    case "${1}" in
        ("A64VN") TARGET=a64_bvN;;
        ("A64VS") TARGET=a64_bvS;;
        ("A64GN") TARGET=a64_bgN;;
        ("64VN") TARGET=arm64_bvN;;
        ("64VS") TARGET=arm64_bvS;;
        ("64GN") TARGET=arm64_bgN;;
        (*) echo "Invalid target - exiting"; exit 1;;
    esac
    lunch lineage_${TARGET}-userdebug

    bash lineage_build_unified/install_prebuilts.sh

    make installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img ~/build-output/lineage-19.1-$BUILD_DATE-UNOFFICIAL-${TARGET}$(${PERSONAL} && echo "-personal" || echo "").img
    make vndk-test-sepolicy
}"

