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

defmodule Strabo.LocationController do
  use Strabo.Web, :controller
  require Logger
  alias Strabo.DataAccess

  # Debug
  alias Strabo.Functions
  alias Strabo.Types, as: T

  def create(conn, %{"lat" => lat, "lon" => lon, "uid" => uid}) do
    :ok = DataAccess.Locations.insert(lat, lon, uid)
    send_resp(conn, conn.status || 200, "OK")
  end

  def upload(conn, params) do
    %{"upload" => %Plug.Upload{filename: user_filename,
                               path: server_filepath}} = params
    Logger.info "got here"
    {:ok, batch_id} = Strabo.Uploader.Locations.upload(server_filepath, params)
    Logger.info "got here too"
    json conn, %{"batch_id" => batch_id}
  end

  # Debug
  def knn(conn, %{"lat" => lat, "lon" => lon}) do
    locations =
      T.make_location(lat,lon)
      |> Functions.nearest_neighbors(5)
    json conn, locations
  end

end
