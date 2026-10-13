cask "mixlab-signed" do
  version "0.129.0"
  sha256 "1e60f950521d8a9e117a93f1437f0f21705a8e1c1211d8eb10460bbdacb328e3"

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
