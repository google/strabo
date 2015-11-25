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

defmodule Strabo.ShapefileController do
  use Strabo.Web, :controller
  require Logger
  alias Strabo.ShapefileManager, as: SM
  alias Strabo.ApiUtil

  def show_shapefiles(conn, %{}) do
    result = SM.get_all_shapefile_statuses()
    json conn, %{"result" => result}
  end

  def install_shapefile(conn, %{"name" => name}) do
    case SM.install_shapefile(name) do
      :ok -> ApiUtil.send_success(conn, %{"message" =>
               "Install started. Shapefile status will be set to 'Installed' when complete."})
      {:error, "Shapefile already installed."} ->
        ApiUtil.send_error(conn, 409, "Shapefile already installed.")
      {:error, "Shapefile not found."} ->
        ApiUtil.send_error(conn, 404, "Shapefile not found.")
    end
  end

  def uninstall_shapefile(conn, %{"name" => name}) do
    case SM.uninstall_shapefile(name) do
      :ok -> ApiUtil.send_success(conn, %{"message" => "OK"})
      {:error, "Shapefile not installed."} ->
        ApiUtil.send_error(conn, 401, "Shapefile not installed.")
      {:error, "Shapefile not found."} ->
        ApiUtil.send_error(conn, 404, "Shapefile not found.")
    end
  end
end
