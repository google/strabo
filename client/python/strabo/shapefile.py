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

from strabo.strabo_object import StraboObject
import requests

class Shapefile(StraboObject):
    """Represents a collection of locations."""
    value_type = Location

    def __init__(self, name = None, **kwargs):
        """Identifies a shapefile by name on the Strabo server.

        Arguments:
        name       -- Specifies the name of the shapefile to be used. A list
                      of available shapefiles can be obtained using the
                      shp_manager tool.
        """
        super(Shapefile, self).__init__(**kwargs)
        assert name is not None
        self.name = batch_id

    def sexpr(self):
        return ("shapefile_from_name", self.name)
