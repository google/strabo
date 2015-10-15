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

defmodule Strabo.PageController do
  use Strabo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def api_index(conn, _params) do
    # TODO(sbrother) Add proper API versioning. For now, we're
    # on version 1.
    json conn, %{"message" => "Welcome to the Strabo API.",
                "version" => 1}
  end
end
