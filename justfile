just := just_executable()
rootdir := ''
prefix := '/usr'

build:
    mkdir -p build
    {{ just }} org.stardustxr.Armillary/build-release
    {{ just }} org.stardustxr.Atmosphere/build-release
    {{ just }} org.stardustxr.BlackHole/build-release
    {{ just }} org.stardustxr.Comet/build-release
    {{ just }} org.stardustxr.Flatland/build-release
    {{ just }} org.stardustxr.Gravity/build-release
    {{ just }} org.stardustxr.NonSpatialInput/build-release
    {{ just }} org.stardustxr.Protostar/build-release
    {{ just }} org.stardustxr.SolarSailer/build-release
    {{ just }} org.stardustxr.Server/build-release

install: build
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Atmosphere/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Armillary/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.BlackHole/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Comet/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Flatland/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Gravity/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.NonSpatialInput/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Protostar/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.SolarSailer/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Server/install

uninstall:
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Armillary/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Atmosphere/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.BlackHole/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Comet/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Flatland/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Gravity/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.NonSpatialInput/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Protostar/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.SolarSailer/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" org.stardustxr.Server/uninstall

prefix-install:
    {{ just }} rootdir="{{ justfile_directory() / 'prefix' }}" install

clean:
    rm -rf org.stardustxr.Armillary/target
    rm -rf org.stardustxr.Atmosphere/target
    rm -rf org.stardustxr.BlackHole/target
    rm -rf org.stardustxr.Comet/target
    rm -rf org.stardustxr.Flatland/target
    rm -rf org.stardustxr.Gravity/target
    rm -rf org.stardustxr.NonSpatialInput/target
    rm -rf org.stardustxr.Protostar/target
    rm -rf org.stardustxr.SolarSailer/target
    rm -rf org.stardustxr.Server/target
