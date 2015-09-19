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

defmodule Strabo.ShapefileManager do
  require Logger
  alias Strabo.DataAccess, as: DB

  @moduledoc """
  Handles downloading shapefiles from the Census Bureau (or other sources),
  importing them into the database, and enabling them for use within
  Strabo queries.
  """

  @shapefile_dir "/tmp"

  @doc """
  Gets a list of all shapefile names and ids, and the current status
  of each (not started, in progress, or installed).
  """
  def get_all_shapefile_statuses() do
    DB.Shapefiles.get_all_shapefiles()
    |> Enum.map &format_shapefile_status/1
  end

  @doc """
  Downloads a shapefile from the location in shapefile.url. If
  successful, sets its status to installed.
  """
  def install_shapefile(shapefile_name) when is_binary(shapefile_name) do
    DB.Shapefiles.get_shapefile_by_name(shapefile_name)
    |> install_shapefile
  end

  @doc """
  Uninstalls a shapefile that has previously been installed.
  """
  def uninstall_shapefile(shapefile_name) when is_binary(shapefile_name) do
    DB.Shapefiles.get_shapefile_by_name(shapefile_name)
    |> uninstall_shapefile
  end

  def uninstall_shapefile(shapefile) do
    case shapefile.status do
      nil -> {:error, "Shapefile not installed."}
      # "in_progress" -> {:error, "Shapefile locked for (un)installation."}
      _ -> 
        :ok = DB.Shapefiles.set_shapefile_status(shapefile.id, "in_progress")
        spawn fn -> start_shapefile_uninstall(shapefile) end
        :ok
    end
  end

  def install_shapefile(shapefile) do
    case shapefile.status do
      "installed" -> {:error, "Shapefile already installed."}
      "in_progress" -> {:error, "Shapefile locked for (un)installation."}
      _ -> 
        :ok = DB.Shapefiles.set_shapefile_status(shapefile.id, "in_progress")
        spawn fn -> start_shapefile_download(shapefile) end
        :ok
    end
  end

  defp format_shapefile_status(shapefile) do
    status =
      case shapefile.status do
        nil           -> "Available"
        "in_progress" -> "In Progress"
        "installed"   -> "Installed"
      end
    %{name: shapefile.name, description: shapefile.description, status: status}
  end

  defp start_shapefile_download(shapefile) do
    shapefile_with_path = %{shapefile | local_path: Path.join(@shapefile_dir,
                                                              shapefile.name <> ".zip")}
    if :filelib.is_regular(shapefile_with_path.local_path) do
      import_shapefile_to_psql(shapefile_with_path)
    else
      case System.cmd("axel", [shapefile.url, "-o", shapefile_with_path.local_path]) do
        {_, 0} ->
          import_shapefile_to_psql(shapefile_with_path)
        {error_message, _} -> cancel_shapefile_download(error_message, shapefile_with_path)
      end
    end
  end

  defp import_shapefile_to_psql(shapefile) do
    unzipped_dir = Path.join(@shapefile_dir, shapefile.name <> "_unzipped")
    sql_script = Path.join(@shapefile_dir, shapefile.name <> "_import.sql")
    case System.cmd("unzip", ["-o", shapefile.local_path, "-d", unzipped_dir]) do
      {_, 0} ->
        case shapefile_path_from_directory(unzipped_dir) do
          {:ok, shapefile_path} ->
            :os.cmd(String.to_char_list(
                  "shp2pgsql -I -s 4326 #{shapefile_path} #{shapefile.db_table_name} > #{sql_script}"))
            import_script(sql_script, shapefile)
          {:error, error_message} -> cancel_shapefile_download(error_message, shapefile)
        end
      {error_message, _} -> cancel_shapefile_download(error_message, shapefile)
    end
  end

  defp import_script(sql_script_path, shapefile) do
    db_params = Ecto.Repo.Config.config(:strabo, Strabo.Repo)
    System.put_env("PGPASSWORD", db_params[:password])
    case System.cmd("psql", ["-U", db_params[:username],
                             "-d", db_params[:database],
                             "-h", db_params[:hostname],
                             "-p", to_string(db_params[:port]),
                             "-f", sql_script_path]) do
      {_, 0} -> 
        DB.Shapefiles.set_shapefile_status(shapefile.id, "installed")
        :ok
      {error_message, _} -> cancel_shapefile_download(error_message, shapefile)
    end
  end

  defp shapefile_path_from_directory(directory) do
    {:ok, files} = :file.list_dir(directory)
    case Enum.find(files, fn s -> String.ends_with?(to_string(s), ".shp") end) do
      nil -> {:error, "No .shp file found in unzipped shapefile"}
      filename ->
        {:ok, Path.join(directory, String.slice(
                  to_string(filename), 0, String.length(to_string(filename)) - 4))}
    end
  end

  defp cancel_shapefile_download(error_message, shapefile) do
    path = shapefile.local_path
    unzipped_dir = Path.join(@shapefile_dir, shapefile.name <> "_unzipped")
    Logger.info "Canceling download of shapefile #{path}"
    _ = :file.delete(path)
    {_, 0} = System.cmd("rm", ["-r", "-f", unzipped_dir])
    DB.Shapefiles.set_shapefile_status(shapefile.id, nil)
    {:error, error_message}
  end

  defp start_shapefile_uninstall(shapefile) do
    DB.Shapefiles.remove_shapefile_from_db(shapefile.db_table_name)
    DB.Shapefiles.set_shapefile_status(shapefile.id, nil)
  end
end
