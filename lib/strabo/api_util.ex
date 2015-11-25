#
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

defmodule Strabo.ApiUtil do
  require Logger

  @doc """
  Returns a successful JSON response.
  """
  def send_success(conn, data \\ %{}) do
    Phoenix.Controller.json(conn, data)
  end

  @doc """
  Return a JSON error response containing a HTTP status code and optional message.
  """
  def send_error(%{resp_headers: resp_headers} = conn, http_status_code, message \\ nil) do
    output_json =
      if message do
        %{"message" => message}
      else
        %{}
      end

    %{conn | resp_headers: [{"content-type", "application/json; charset=utf-8"} | resp_headers]}
    |> Plug.Conn.send_resp(http_status_code, Poison.encode!(output_json))
  end
end
