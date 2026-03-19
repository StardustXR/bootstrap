just := just_executable()

build:
    mkdir -p build
    {{ just }} server/build-release
    {{ just }} flatland/build-release
    {{ just }} comet/build-release

install rootdir="" prefix="/usr/local": build
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" server/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" flatland/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" comet/install

uninstall rootdir="" prefix="/usr/local":
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" server/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" flatland/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" comet/uninstall

prefix-install: (install (invocation_directory() / "prefix") "/usr/local")

clean:
    rm -rf server/target
    rm -rf flatland/target
