{ lib,
# from release-lib
unix, linux, darwin, cygwin, all, mesaPlatforms,
x11Supported,
gtkSupported,
ghcSupported,
...
}:
rec {
  nativePlatforms = linux;

  common = {
    buildPackages.binutils = nativePlatforms;
    gmp = nativePlatforms;
    libcCross = nativePlatforms;
  };

  gnuCommon = lib.recursiveUpdate common {
    buildPackages.gcc = nativePlatforms;
    coreutils = nativePlatforms;
  };

  linuxCommon = lib.recursiveUpdate gnuCommon {
    buildPackages.gdb = nativePlatforms;
    buildPackages.valgrind = nativePlatforms;

    bison = nativePlatforms;
    busybox = nativePlatforms;
    dropbear = nativePlatforms;
    ed = nativePlatforms;
    ncurses = nativePlatforms;
    patch = nativePlatforms;
  };

  small = lib.recursiveUpdate linuxCommon {
    aspell = all;
    at = linux;
    atlas = linux;
    autoconf = all;
    automake = all;
    avahi = unix; # Cygwin builds fail
    bash = all;
    bashInteractive = all;
    bc = all;
    binutils = linux;
    bind = linux;
    bsdiff = all;
    bzip2 = all;
    classpath = linux;
    cmake = all;
    coreutils = all;
    cpio = all;
    cron = linux;
    cups = linux;
    dbus = linux;
    dhcp = linux;
    diffutils = all;
    e2fsprogs = linux;
    emacs25 = gtkSupported;
    enscript = all;
    file = all;
    findutils = all;
    flex = all;
    gcc = all;
    gcc7 = all;
    gcj = linux;
    glibc = linux;
    # glibcLocales = linux;
    gnat = linux;
    gnugrep = all;
    gnum4 = all;
    gnumake = all;
    gnupatch = all;
    gnupg = linux;
    gnuplot = unix; # Cygwin builds fail
    gnused = all;
    gnutar = all;
    gnutls = linux;
    gogoclient = linux;
    grub = linux;
    grub2 = linux;
    gsl = linux;
    guile = linux;  # tests fail on Cygwin
    gzip = all;
    hddtemp = linux;
    hdparm = linux;
    hello = all;
    host = linux;
    iana-etc = linux;
    icewm = linux;
    idutils = all;
    inetutils = linux;
    iputils = linux;
    jnettop = linux;
    jwhois = linux;
    kbd = linux;
    keen4 = ["i686-linux"];
    kvm = linux;
    qemu = linux;
    qemu_kvm = linux;
    less = all;
    lftp = all;
    liblapack = linux;
    libtool = all;
    libtool_2 = all;
    libxml2 = all;
    libxslt = all;
    lout = linux;
    lsh = linux;
    lsof = linux;
    ltrace = linux;
    lvm2 = linux;
    lynx = linux;
    lzma = linux;
    man = linux;
    man-pages = linux;
    mc = all;
    mcabber = linux;
    mcron = linux;
    mdadm = linux;
    mesa = mesaPlatforms;
    midori = linux;
    mingetty = linux;
    mk = linux;
    mktemp = all;
    mono = linux;
    # monotone = linux;
    mpg321 = linux;
    mutt = linux;
    mysql = linux;
    netcat = all;
    nfs-utils = linux;
    nix = all;
    nixUnstable = all;
    nss_ldap = linux;
    nssmdns = linux;
    ntfs3g = linux;
    ntp = linux;
    openssh = linux;
    openssl = all;
    pan = gtkSupported;
    par2cmdline = all;
    pciutils = linux;
    pdf2xml = all;
    perl = all;
    pkgconfig = all;
    pmccabe = linux;
    procps = linux;
    python = unix; # Cygwin builds fails
    readline = all;
    rlwrap = all;
    rpm = linux;
    rpcbind = linux;
    rsync = linux;
    screen = linux ++ darwin;
    scrot = linux;
    sdparm = linux;
    sharutils = all;
    sloccount = unix; # Cygwin builds fail
    smartmontools = all;
    sqlite = unix; # Cygwin builds fail
    squid = linux;
    ssmtp = linux;
    stdenv = all;
    strace = linux;
    su = linux;
    sudo = linux;
    sysklogd = linux;
    syslinux = ["i686-linux"];
    sysvinit = linux;
    sysvtools = linux;
    tcl = linux;
    tcpdump = linux;
    texinfo = all;
    time = linux;
    tinycc = linux;
    udev = linux;
    unar = linux;
    unzip = all;
    usbutils = linux;
    utillinux = linux;
    utillinuxMinimal = linux;
    w3m = all;
    webkit = linux;
    wget = all;
    which = all;
    wicd = linux;
    wireshark = linux;
    wirelesstools = linux;
    wpa_supplicant = linux;
    xfsprogs = linux;
    xkeyboard_config = linux;
    zile = linux;
    zip = all;
  };

  # XXX: Move elsewhere
  compilers = {
    gcc45 = all;
    gcc48 = all;
    gcc49 = all;
    gcc5 = all;
    gcc6 = all;
    gcc7 = all;
    gcc8 = all;
    clang_4 = all;
    clang_5 = all;
    clang_6 = all;
    llvm_4 = all;
    llvm_5 = all;
    llvm_6 = all;
  };

  servers = {
    mariadb = all;
    memcached = all;
    nginxMainline = all;
    nginxStable = all;
    openntpd = all;
    postgresql = all;
    siege = all;
    squid = all;
    squid4 = all;
  };

  misc = {
    bloaty = all;
    brotli = all;
    curl = all;
    git = all;
    iproute = all;
    jq = all;
    libiconv = all;
    links2 = all;
    linux = all;
    linuxPackages.cpupower = all;
    linux_latest = all;
    lldb_4 = all;
    lldb_5 = all;
    nettools = all;
    nix-info = all;
    nox = all;
    psmisc = all;
    python2 = all;
    python2Packages.csvkit = all;
    python3 = all;
    python3Packages.csvkit = all;
    range-v3 = all;
    rhash = all;
    taskwarrior = all;
    termite = all;
    timewarrior = all;
    tmux = all;
    vim = all;
    xterm = all;
    xz = all;
    zsh = all;
  };

  ghcs = let ghcPkgs = { ghc = nativePlatforms; hello = nativePlatforms; }; in {
    ghc = nativePlatforms;
    haskell.packages.ghc822 = ghcPkgs;
    haskell.packages.ghc841 = ghcPkgs;
    haskell.packages.ghc843 = ghcPkgs;
  };
}
