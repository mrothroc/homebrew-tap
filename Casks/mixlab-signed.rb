cask "mixlab-signed" do
  version "0.126.0"
  sha256 "72f9b1a11f642fa8d3e228defe4d3b9875cf938f8e637a1873e4cb9219dcd5b8"

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
