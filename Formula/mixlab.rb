class Mixlab < Formula
  desc "ML architecture exploration tool — JSON configs, Go IR, Metal/CUDA"
  homepage "https://github.com/mrothroc/mixlab"
  url "https://github.com/mrothroc/mixlab.git",
      tag:      "v0.118.0",
      revision: "7b72184d055e8a17fccffed66360e7e4ae16d182"
  license "MIT"
  head "https://github.com/mrothroc/mixlab.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
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
  end

  # Runs without a GPU: the version the linker stamped, then a config parsed and
  # lowered to IR, which also proves the MLX library loads.
  test do
    assert_match "mixlab v#{version} ", shell_output("#{bin}/mixlab -version") unless version.head?
    (testpath/"model.json").write <<~JSON
      {"model_dim": 16, "vocab_size": 32, "seq_len": 4,
       "blocks": [{"type": "plain", "heads": 2}], "training": {"batch_tokens": 4}}
    JSON
    assert_match "valid config", shell_output("#{bin}/mixlab -mode validate -config #{testpath}/model.json")
  end
end
