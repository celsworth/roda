require File.expand_path("helper", File.dirname(__FILE__))

setup do
  { "SCRIPT_NAME" => "/", "PATH_INFO" => "/posts/123" }
end

test "text-book example" do |env|
  Cuba.define do
    on "posts/:id" do |id|
      res.write id
    end
  end

  _, _, resp = Cuba.call(env)

  assert_equal ["123"], resp.body
end

test "multi-param" do |env|
  Cuba.define do
    on "u/:uid/posts/:id" do |uid, id|
      res.write uid
      res.write id
    end
  end

  env["PATH_INFO"] = "/u/jdoe/posts/123"

  _, _, resp = Cuba.call(env)

  assert_equal ["jdoe", "123"], resp.body
end

test "regex nesting" do |env|
  Cuba.define do
    on /u\/(\w+)/ do |uid|
      res.write uid

      on /posts\/(\d+)/ do |id|
        res.write id
      end
    end
  end

  env["PATH_INFO"] = "/u/jdoe/posts/123"

  _, _, resp = Cuba.call(env)

  assert_equal ["jdoe", "123"], resp.body
end

test "regex nesting colon param style" do |env|
  Cuba.define do
    on /u:(\w+)/ do |uid|
      res.write uid

      on /posts:(\d+)/ do |id|
        res.write id
      end
    end
  end

  env["PATH_INFO"] = "/u:jdoe/posts:123"

  _, _, resp = Cuba.call(env)

  assert_equal ["jdoe", "123"], resp.body
end

test "symbol matching" do |env|
  Cuba.define do
    on path("user"), :id do |uid|
      res.write uid

      on path("posts"), :pid do |id|
        res.write id
      end
    end
  end

  env["PATH_INFO"] = "/user/jdoe/posts/123"

  _, _, resp = Cuba.call(env)

  assert_equal ["jdoe", "123"], resp.body
end

__END__
test "benchmarks" do |env|
  require "benchmark"

  Cuba.define do
    on "posts/:id" do |id|
      res.write id
    end
  end

  t1 = Benchmark.realtime {
    10_000.times { _, _, resp = Cuba.call(env) }
  }

  Cuba.reset!

  Cuba.define do
    on path("posts"), segment do |id|
      res.write id
    end
  end

  t2 = Benchmark.realtime {
    10_000.times { _, _, resp = Cuba.call(env) }
  }

  puts t1
  puts t2
end