class Mixlab < Formula
  desc "ML architecture exploration tool — JSON configs, Go IR, Metal/CUDA"
  homepage "https://github.com/mrothroc/mixlab"
  url "https://github.com/mrothroc/mixlab.git",
      tag:      "v0.119.0",
      revision: "6c5f748307290548b1dc9d432aca20ab992efa3a"
  license "MIT"
  head "https://github.com/mrothroc/mixlab.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/mrothroc/homebrew-tap/releases/download/mixlab-0.118.0"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "43eb845d9d519fddf8ede98531e7107fd6068e92a5e9231a7f067a12cd3a7bb3"
    sha256 cellar: :any, arm64_sequoia: "92bd9e7d249777b1dfd5f580f4314d1ec1ac37a978b4f7021c583a3c850bc489"
  end

  # Homebrew has no versioned mlx formula and depends_on takes no version
  # predicate, so the tested range is enforced here. MLX 0.32.1 changed gather
  # VJP semantics under a patch bump and silently broke MoE and bf16 training, so
  # an untested MLX is refused rather than allowed through. These must match
  # packaging/mlx-tested-range.txt in the mixlab source; widen both together, only
  # after the -tags mlx suite passes on the new MLX.
  MLX_TESTED_MINIMUM = "0.32.0".freeze
  MLX_TESTED_BELOW = "0.33.0".freeze

  # Pouring a bottle skips install, so the range must also gate the bottle. With
  # an untested MLX this falls back to a source build, where install refuses it.
  pour_bottle? do
    reason "The mixlab bottle needs mlx >= #{MLX_TESTED_MINIMUM} and < #{MLX_TESTED_BELOW}."
    satisfy { Mixlab.mlx_tested? }
  end

  depends_on "go" => :build
  depends_on :macos
  depends_on "mlx"

  def self.mlx_tested?
    mlx = Formula["mlx"].version
    mlx >= Version.new(MLX_TESTED_MINIMUM) && mlx < Version.new(MLX_TESTED_BELOW)
  end

  def install
    unless self.class.mlx_tested?
      odie <<~EOS
        mixlab #{version} is tested against MLX >=#{MLX_TESTED_MINIMUM} <#{MLX_TESTED_BELOW}, but Homebrew has mlx #{Formula["mlx"].version}.

        MLX changes numerical and autodiff behavior in patch releases, so an
        untested version can break training in ways that only show up mid-run.
        Install a supported mlx, or widen the range here and in
        packaging/mlx-tested-range.txt after the -tags mlx suite passes.
      EOS
    end

    mlx = formula_opt_prefix("mlx")
    ENV["CGO_ENABLED"] = "1"
    ENV.append "CGO_CFLAGS", "-I#{mlx}/include"
    ENV.append "CGO_CXXFLAGS", "-I#{mlx}/include -std=c++20"
    ENV.append "CGO_LDFLAGS", "-L#{mlx}/lib -Wl,-rpath,#{mlx}/lib"
    system "go", "build", *std_go_args(tags: "mlx"), "./cmd/mixlab"
    # mixlab-cluster links no MLX. cgo stays on for its default macOS Keychain
    # key storage; without cgo only file-backed keys would be available.
    system "go", "build", *std_go_args(output: bin/"mixlab-cluster"), "./cmd/mixlab-cluster"
  end

  # Runs without a GPU: the version the linker stamped, then a config parsed and
  # lowered to IR, which also proves the MLX library loads, then a cluster
  # identity created offline.
  test do
    assert_match "mixlab v#{version} ", shell_output("#{bin}/mixlab -version") unless version.head?
    (testpath/"model.json").write <<~JSON
      {"model_dim": 16, "vocab_size": 32, "seq_len": 4,
       "blocks": [{"type": "plain", "heads": 2}], "training": {"batch_tokens": 4}}
    JSON
    assert_match "valid config", shell_output("#{bin}/mixlab -mode validate -config #{testpath}/model.json")

    # Creates a cluster identity offline: no socket is opened and file-backed
    # keys keep the test out of the Keychain.
    assert_match "mixlab-cluster v#{version} ", shell_output("#{bin}/mixlab-cluster -version") unless version.head?
    state = testpath.realpath/"cluster-state"
    init = JSON.parse(shell_output("#{bin}/mixlab-cluster init -state-home #{state} -key-backend file"))
    assert_match(/\A\h{32}\z/, init["cluster"])
    assert_equal %w[authority controller coordinator], init["principals"].map { |p| p["role"] }.sort
  end
end
