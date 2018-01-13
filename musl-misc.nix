{ nixpkgs
, supportedSystems ? [ "x86_64-linux" ]
, # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
,  nixpkgsArgs ? { config = { allowUnfree = false; inHydra = true; }; }
}:

let
  release-lib = import ./support/release-musl-native-lib.nix {
    inherit supportedSystems scrubJobs nixpkgs nixpkgsArgs;
  };
in
  with release-lib;
  with import ./support/job-groups.nix release-lib;

{
  misc = mapTestOn {
    squid = linux;
    squid4 = linux;

    cyrus_sasl = linux;
    ldns = linux;
    nettle = linux;
    openssh = linux;
    openssl = linux;
    openssl_1_1_0 = linux;
    p11_kit = linux;
    unbound = linux;

    audit = linux;
    libapparmor = linux;
    libusb = linux;
    libnl = linux;
    utillinux = linux;
    wirelesstools = linux;

    SDL = linux;
    SDL2 = linux;

    gtk2 = linux;
    gtk3 = linux;

    asio = linux;
    glib = linux;
    libnet  = linux;
    tbb = linux;

    guile = linux;

    pulseaudioLight = linux;
    # pulseaudioFull = linux;
    webrtc-audio-processing = linux;

    dbus = linux;

    # unfree
    # boolector = linux;
    eprover = linux;
    picosat = linux;
  };

}

