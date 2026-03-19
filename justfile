just := just_executable()

build:
    mkdir -p build
    {{ just }} server/build-release
    {{ just }} flatland/build-release

install rootdir="" prefix="/usr/local": build
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" server/install
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" flatland/install

uninstall rootdir="" prefix="/usr/local":
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" server/uninstall
    {{ just }} rootdir="{{ rootdir }}" prefix="{{ prefix }}" flatland/uninstall

prefix-install: (install (invocation_directory() / "prefix") "/usr/local")

clean:
    rm -rf server/target
    rm -rf flatland/target
