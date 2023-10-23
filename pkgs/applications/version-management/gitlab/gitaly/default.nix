{ lib
, fetchFromGitLab
, fetchFromGitHub
, buildGoModule
, pkg-config
}:

let
  version = "16.5.0";
  package_version = "v${lib.versions.major version}";
  gitaly_package = "gitlab.com/gitlab-org/gitaly/${package_version}";

  commonOpts = {
    inherit version;

    src = fetchFromGitLab {
      owner = "gitlab-org";
      repo = "gitaly";
      rev = "v${version}";
      hash = "sha256-3TMf9XKaTaIYg93wWXnsj+ckmMWzX/fbwUIFu3y2AwM=";
    };

    vendorHash = "sha256-QLt/12P6OLpLqCINROLmzhoRpLGrB9WzME7FzhIcb0Q=";

    ldflags = [ "-X ${gitaly_package}/internal/version.version=${version}" "-X ${gitaly_package}/internal/version.moduleVersion=${version}" ];

    tags = [ "static" ];

    nativeBuildInputs = [ pkg-config ];

    doCheck = false;
  };

  auxBins = buildGoModule ({
    pname = "gitaly-aux";

    subPackages = [ "cmd/gitaly-hooks" "cmd/gitaly-ssh" "cmd/gitaly-lfs-smudge" "cmd/gitaly-gpg" ];
  } // commonOpts);
in
buildGoModule ({
  pname = "gitaly";

  subPackages = [ "cmd/gitaly" "cmd/gitaly-backup" ];

  preConfigure = ''
    mkdir -p _build/bin
    cp -r ${auxBins}/bin/* _build/bin
  '';

  outputs = [ "out" ];

  meta = with lib; {
    homepage = "https://gitlab.com/gitlab-org/gitaly";
    description = "A Git RPC service for handling all the git calls made by GitLab";
    platforms = platforms.linux ++ [ "x86_64-darwin" ];
    maintainers = with maintainers; [ roblabla globin talyz yayayayaka ];
    license = licenses.mit;
  };
} // commonOpts)
