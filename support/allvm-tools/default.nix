{ stdenv
, src
#, rangev3 # only in analysis branch
, python2 # lit?
, llvm
, lld
, zlib
, cmake
, git
, clang-format ? null
, disableHardening ? false
, stripReferences ? true
, nukeReferences ? null
, buildDocs ? (stdenv.buildPlatform == stdenv.hostPlatform)
, pandoc ? null
, texlive ? null
}:

assert stripReferences -> (nukeReferences != null);
assert buildDocs -> (pandoc != null);
assert buildDocs -> (texlive != null);

let
  tex = texlive.combine {
    inherit (texlive) scheme-medium;
  };
  versionSuffix = "${toString src.revCount}-${src.shortRev}";
  version = "0.1-${versionSuffix}";
in
stdenv.mkDerivation ({
  name = "allvm-tools-${version}";
  inherit version;
  inherit src;

  enableParallelBuilding = true;

  hardeningDisable = stdenv.lib.optional disableHardening "all";

  nativeBuildInputs = [ clang-format python2 cmake ]
    ++ stdenv.lib.optionals buildDocs [ tex pandoc ]
    ++ stdenv.lib.optional stripReferences nukeReferences;
  buildInputs = [ zlib llvm lld ];

  doCheck = true; # not cross

  cmakeFlags = [
    "-DGITVERSION=${versionSuffix}"
    #"-DCMAKE_VERBOSE_MAKEFILE=1"
  ] ++ stdenv.lib.optional (clang-format != null) "-DCLANGFORMAT=${clang-format}/bin/clang-format";

  # If we had a 'check' target we wouldn't need to specify what to do,
  # but since folks might not build with clang-format available the check-format
  # stuff must be manually invoked and not automatically part of testing.
  checkPhase = ''
    make check
    [ -f bin/alld ] || (echo "alld not found!"; exit 1)
    ls -l bin/alld
  '' + stdenv.lib.optionalString (clang-format != null) ''
    make check-format
  '';

  postBuild = stdenv.lib.optionalString (!stdenv.isMips) ''
    paxmark m bin/alley
  '';

  postInstall = stdenv.lib.optionalString stripReferences ''
    nuke-refs -e ${stdenv.cc.libc.out} -e ${zlib} -e $out $out/bin/* $out/lib/*
  '';

} // stdenv.lib.optionalAttrs stripReferences {
  allowedReferences = [ stdenv.cc.libc.out zlib ];
})
