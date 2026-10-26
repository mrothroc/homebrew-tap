class Mailpipe < Formula
  desc "Reviewed Microsoft 365 mailbox processing for agents"
  homepage "https://github.com/mrothroc/mailpipe"
  url "https://github.com/mrothroc/mailpipe/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "8dee3316dfacafdce84d96710e38aa49613aeb6fb1b9bc8a6ca0fa997afca5e4"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "go" => :build
  depends_on :macos

  def install
    ENV["GOTOOLCHAIN"] = "local"
    system "go", "build", *std_go_args, "./cmd/mailpipe"
    pkgshare.install "examples"
  end

  test do
    assert_match "Microsoft 365", shell_output("#{bin}/mailpipe --help")
    assert_path_exists pkgshare/"examples/stages.example.json"
    assert_predicate pkgshare/"examples/stages/newsletter.sh", :executable?

    # Exercise the installed CLI without a mailbox, model account or Keychain.
    ENV.delete "MAILPIPE_CLIENT_ID"
    ENV.delete "MAILPIPE_TENANT_ID"
    ENV["MAILPIPE_CONFIG"] = (testpath/"config.json").to_s
    system bin/"mailpipe", "config", "init",
           "--client-id", "11111111-1111-4111-8111-111111111111",
           "--tenant-id", "22222222-2222-4222-8222-222222222222"
    config = JSON.parse((testpath/"config.json").read)
    assert_equal "11111111-1111-4111-8111-111111111111", config["client_id"]
    assert_match config["tenant_id"], shell_output("#{bin}/mailpipe config show --json")
    assert_equal 0600, (testpath/"config.json").stat.mode & 0777
  end
end
