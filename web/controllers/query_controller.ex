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

defmodule Strabo.QueryController do
  use Strabo.Web, :controller
  require Logger
  alias Strabo.Compiler, as: C

  def run(conn, %{"q" => query}) do
    compiled_query =
      query
      |> C.Lexer.tokenize
      |> C.Parser.parse(Strabo.Functions)
      |> C.Parser.compile
    result = compiled_query.()
    Logger.info "Result before encoding: #{inspect result}"
    json conn, %{"result" => result}
  end
end
