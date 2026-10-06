cask "mixlab-signed" do
  version "0.125.0"
  sha256 "c1b75e48a4bd15dcb05003227cc3321b16c38d0f31d00345e136123adda76375"

  url "https://github.com/mrothroc/mixlab/releases/download/v#{version}/mixlab-v#{version}-macos-arm64.dmg"
  name "Mixlab"
  desc "Signed training and managed cluster executables"
  homepage "https://github.com/mrothroc/mixlab"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  suite "mixlab-macos-arm64", target: "Mixlab"
  binary "#{appdir}/Mixlab/mixlab"
  binary "#{appdir}/Mixlab/mixlab-cluster"

  caveats <<~EOS
    Unlink the source-built mixlab formula before installing this cask.
    Enroll first, then use mixlab-cluster authority install and agent install.
    Services require a logged-in GUI session and initial Local Network approval.
    Before upgrading or uninstalling: finish jobs, then stop agent and authority
    services. After upgrading: agent reapprove -worker-binary "$(command -v mixlab)"
    on each node, then start services. Identities and datasets are preserved.
    Uninstall service registrations explicitly before removing this cask.
  EOS
end
