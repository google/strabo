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

  def show_shapefiles(conn, %{}) do
    result = SM.get_all_shapefile_statuses()
    json conn, %{"result" => result}
  end

  def install_shapefile(conn, %{"name" => name}) do
    :ok = SM.install_shapefile(name)
    json conn, %{"message" => "OK"}
  end

  def uninstall_shapefile(conn, %{"name" => name}) do
    :ok = SM.uninstall_shapefile(name)
    json conn, %{"message" => "OK"}
  end
end
