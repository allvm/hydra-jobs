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
  servers = mapTestOn {
    squid = linux;
    squid4 = linux;
  };

  crypto = mapTestOn {
    cyrus_sasl = linux;
    gnutls = linux;
    ldns = linux;
    nettle = linux;
    openssh = linux;
    openssl = linux;
    openssl_1_1_0 = linux;
    p11_kit = linux;
    unbound = linux;
  };

  system = mapTestOn {
    audit = linux;
    libapparmor = linux;
    libtirpc = linux;
    libusb = linux;
    libnl = linux;
    utillinux = linux;
    wirelesstools = linux;

    systemd = linux;
  };

  desktop = mapTestOn {
    SDL = linux;
    SDL2 = linux;

    gtk2 = linux;
    gtk3 = linux;

    qt4 = linux;

    qt5.qtbase = linux;

    mesa = linux;

    xorg.xorgserver = linux;

    pulseaudioLight = linux;
    # pulseaudioFull = linux;
    webrtc-audio-processing = linux;

    dbus = linux;

    termite = linux;
  };


  libs = mapTestOn {
    asio = linux;
    glib = linux;
    libnet  = linux;
    tbb = linux;
  };

  langs = mapTestOn {
    autogen = linux;
    guile = linux;
    go = linux;
  };

  math = mapTestOn {
    aiger = linux;
    avy = linux;
    cvc3 = linux;
    cvc4 = linux;
    eprover = linux;
    picosat = linux;
    yices = linux;

    openblas = linux;
  };

}

