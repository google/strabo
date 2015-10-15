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

import requests

STRABO_DEFAULT_URL = 'localhost:4001'

class StraboConnection(object):
    def __init__(self, strabo_url = None):
        if strabo_url is None:
            strabo_url = STRABO_DEFAULT_URL
        self.strabo_url = self.get_api_url(strabo_url)
        self.api_version = self.get_api_version()

    def get_api_url(self, strabo_url):
        api_url = ""
        # Add http:// in front of URL if necessary; required for requests module.
        if not strabo_url.startswith("http://"):
            api_url += "http://"

        # Remove trailing /
        if strabo_url.endswith("/"):
            api_url += strabo_url[:-1]
        else:
            api_url += strabo_url

        # Add /api if not already present
        if not api_url.endswith("/api"):
            api_url += "/api"
        return api_url

    def get_api_version(self):
        response = requests.get(self.strabo_url)
        response.raise_for_status()
        response_json = response.json()
        if 'version' not in response_json:
            raise ValueError("Did not receive API version from Strabo server.")
        return response_json['version']

    def run(self, strabo_object):
        payload = {'q': strabo_object.compile()}
        response = requests.get(self.strabo_url + "/query", params=payload)
        response.raise_for_status()
        return response.json()
