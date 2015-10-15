# Copyright 2015 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

defmodule Strabo.Tests.Compiler do
  use ExUnit.Case
  require Logger
  alias Strabo.Compiler, as: C

  defmodule TestEnv do
    def add_one(x), do: x + 1
    def add(x, y), do: x + y
    def cat(x, y), do: x<>y
    def test_args(1, "xy", 6), do: true
    def test_args(_, _, _), do: false
    def map(f, xs), do: Enum.map(xs, f)
    def make_list(x, y, z), do: [x, y, z]
  end

  test "SimpleTokenization" do
    assert C.Lexer.tokenize("(add_one 1)") == ["(", "add_one", 1, ")"]
    assert C.Lexer.tokenize("(hello 22 -3.4)") == ["(", "hello", 22, -3.4, ")"]
  end

  test "SimpleParsing" do
    f = ["(", "add_one", 1, ")"]
    |> C.Parser.parse(Strabo.Tests.Compiler.TestEnv)
    |> C.Parser.compile
    assert f.() == 2

    f = ["(", "test_args", 1, "(", "cat", "x", "y", ")", 6, ")"]
    |> C.Parser.parse(Strabo.Tests.Compiler.TestEnv)
    |> C.Parser.compile
    assert f.() == true
  end

  test "EndToEnd" do
    f = "(add (add_one (add_one 3)) 6)"
    |> C.Lexer.tokenize
    |> C.Parser.parse(Strabo.Tests.Compiler.TestEnv)
    |> C.Parser.compile
    assert f.() == 11
  end

  test "EndToEndWithArgs" do
    f = "(add 5 $1)"
    |> C.Lexer.tokenize
    |> C.Parser.parse(Strabo.Tests.Compiler.TestEnv)
    |> C.Parser.compile
    assert f.(8) == 13
  end

  test "BackwardArgs" do
    f = "(cat $2 $1)"
    |> C.Lexer.tokenize
    |> C.Parser.parse(Strabo.Tests.Compiler.TestEnv)
    |> C.Parser.compile
    assert f.("i", "h") == "hi"
  end

  test "SimpleLambda" do
    f = "(map (lambda (arg) (add_one (arg))) (make_list 4 5 6))"
    |> C.Lexer.tokenize
    |> C.Parser.parse(Strabo.Tests.Compiler.TestEnv)
    |> C.Parser.compile
    assert f.() == [5, 6, 7]
  end

end
