# Run this with `ruby test.rb`

require 'test/unit'

class ILoveOOP < Test::Unit::TestCase
  def quine?(file)
    sha1 = `sha1sum #{file}`.split(/\s/)[0]
    sha2 = `#{file} 2>/dev/null | sha1sum`.split(/\s/)[0]
    sha1 == sha2
  end

  def test_quineness
    assert(quine?("./quinedb"), "isn't even a quine")
  end

  def setup
    `rm -rf tmp/test`
    `mkdir -p tmp/test`
    `cp quinedb tmp/test/quinedb`
  end

  def teardown
    `rm -rf tmp`
  end

  def pr_str s
  	"'#{s.gsub(/'/, "'\\\\''")}'"
  end

  def cmd *args
    args = args.map{|x|pr_str x}.join(" ")
    `tmp/test/quinedb #{args} > tmp/test/out 2> tmp/test/err`
    `mv tmp/test/out tmp/test/quinedb`
    `chmod +x tmp/test/quinedb`
    res = `cat tmp/test/err`
    `rm tmp/test/err`
    res.strip
  end

  def test_basic_crud
    assert(cmd("keys") == "")
    assert(quine?("tmp/test/quinedb"))
    assert(cmd("set","k","v") == "OK")
    assert(quine?("tmp/test/quinedb"))
    assert(cmd("keys") == "k")
    assert(quine?("tmp/test/quinedb"))
    assert(cmd("set","k2","v2") == "OK")
    assert(quine?("tmp/test/quinedb"))
    assert(cmd("keys").split(/\n/).sort == %w(k k2))
    assert(cmd("get","k") == "v")
    assert(cmd("get","k2") == "v2")
    assert(cmd("delete","k2") == "OK")
    assert(cmd("get","k2") == "")
    assert(cmd("get","k") == "v")
    assert(quine?("tmp/test/quinedb"))
  end

  # TODO: write some more tests
end
